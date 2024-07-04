#include 'OGAA580.CH'
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

static _N9HExcl    := ""  //tabela N9H exclusiva?
static _lCopy       := .F.
/*{Protheus.doc} OGA580
//TODO Descrição auto-gerada.
@author Jefferson
@since 18/04/2018
@Uso:       SIGAAGR - Agorindustria
@version undefined

@type function
/*/
Function OGAA580(pcSafra, pcCodProd )
  Local aArea      := GetArea()
  Local cFiltroDef := ""
  Private oBrowse  := Nil
  Private dtVigen := "" 
  
  //Proteç?o
	If !TableInDic('N9H')
		Help( , , STR0010, , STR0051, 1, 0 ) //"Atenç?o" //"Para acessar esta funcionalidade é necessario atualizar a tabela 'Usuario Portal Agro' ."
		Return(Nil)
	EndIf 

   Do Case
    Case !Empty( pcSafra ) .And. !Empty( pcCodProd )
      cFiltroDef := " N9H_CODSAF = '"+pcSafra+"' .AND. N9H_PROD = '"+pcCodProd+"'
    Case Empty( pcSafra ) .And. !Empty( pcCodProd )
      cFiltroDef := " N9H_PROD = '"+pcCodProd+"'
    Case !Empty( pcSafra ) .And. Empty( pcCodProd )
      cFiltroDef := " N9H_CODSAF = '"+pcSafra+"'
  EndCase


  //-------------------------
  //Instancia o objeto Browse
  //-------------------------
  _N9HExcl := FWModeAccess("N9H", 3) == "E"
  oBrowse := FWMBrowse():New( , , , , , , , , , ,)
  oBrowse:SetAlias('N9H')
  oBrowse:SetDescription( STR0001 ) //"Cadastro de Indices por Tabela"
  oBrowse:SetFilterDefault( cFiltroDef )
  oBrowse:SetAttach(.T.)
  oBrowse:Activate()

  RestArea(aArea)
Return ()


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo MVC
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
  Local oModel      := Nil
  Local oStruN9H      := nil
  Local oStruN9HGrd   := nil

  If FWIsInCallStack("OGAA580AAUX") .OR. FWIsInCallStack("OGAA580CPY")
    oStruN9H      := FwFormStruct( 1, "N9H", {|cCampo|  ALLTRIM(cCampo) $ "N9H_VLINDT|N9H_OBSERV|N9H_UNIMED" } )
    oStruN9HGrd   := FWFormStruct( 1, 'N9H', )

    oModel := MpFormModel():New( "OGA580",/*bPre*/ , {|oModel| PosModel(oModel)} , {|oModel| SaveModel(oModel)} , /*bCancel*/ )
    oModel:SetDescription( STR0008 )  //Alteração Indíces por Tabela

    If _N9HExcl
      oStruN9HGrd:AddField(                 ;   // Ord. Tipo Desc.
              STR0020, ;  //Filial              // [01] C Titulo do campo
              STR0021, ;  //Código da Filial    // [02] C Descrição do campo
              "N9H_FILIAL",                 ;   // [03] C identificador (ID) do
              TamSX3( "N9H_FILIAL" )[3],    ;   // [04] C Tipo do campo
              TamSX3( "N9H_FILIAL" )[1] ,   ;   // [05] N Tamanho do campo
              TamSX3( "N9H_FILIAL" )[2] ,   ;   // [06] N Decimal do campo
              nil, ;                            // [07] B Code-block de validação do campo
              nil, ;                            // [08] B Code-block de WHEN
              {}, ;                             // [09] A Lista de valores permitido do campo combo
              .F. , ;                           // [10] L Indica se o campo tem preenchimento obrigatório
              nil , ;                           // [11] B Code-block de inicializacao do campo
              NIL    , ;                        // [12] L Indica se trata de um campo chave
              NIL , ;                           // [13] L Indica se o campo pode receber valor em uma operação de update.
              .T. )
    EndIf


    MntStruct(@oStruN9H, "Model")
    
    oStruN9H:AddTrigger( "TMP_INDICE", "TMP_UNIMED", { || .T. }, { | oField, x | TriggerUNM( oField, '1' )} )

    oModel:AddFields( "OGAA580_N9H", , oStruN9H,/*bPre*/ ,/*bPost*/ ,/*bLoad*/ )
    oModel:AddGrid ( 'MODEL_GRID', 'OGAA580_N9H', oStruN9HGrd, ,  , , ,)

    oModel:GetModel("MODEL_GRID"):SetNoInsertLine(.T.)
    oModel:GetModel("MODEL_GRID"):SetNoDeleteLine(.T.)

    oModel:SetPrimaryKey( { "N9H_FILIAL", "N9H_INDICE", "N9H_PROD", "N9H_CODSAF", "N9H_ITETAB", "N9H_UFORIG", "N9H_UFDEST", "N9H_DTINVG", "N9H_CODREG" } )

    oModel:SetVldActivate(  { | oModel | VldActveMd( oModel, oModel:GetOperation() ) })
    oModel:SetActivate(   { | oModel | ActivateMD( oModel, oModel:GetOperation() ) } )

  Else
    oStruN9H      := FwFormStruct( 1, "N9H", {|cCampo| !ALLTRIM(cCampo) $ "N9H_ITETAB|N9H_TIPO|N9H_DTIPO|N9H_VLINDT|N9H_OBSERV|N9H_UNIMED" } )
    oStruN9HGrd   := FWFormStruct( 1, 'N9H', {|cCampo|  ALLTRIM(cCampo) $ "N9H_ITETAB|N9H_TIPO|N9H_DTIPO|N9H_VLINDT|N9H_OBSERV|N9H_UNIMED" } )

    oModel := MpFormModel():New( "OGA580",/*bPre*/ , {|oModel| PosModel(oModel)}, {|oModel| GrvModel(oModel)} , /*bCancel*/ )
    oModel:SetDescription( STR0001 ) //Cadastro de  Indíces por Tabela

    oStruN9H:AddTrigger( "N9H_PROD"  , "TMP_VALOR",  { || .T. }, { | oField | TriggerVlr( oField ) } )
    oStruN9H:AddTrigger( "N9H_INDICE", "TMP_UNIMED", { || .T. }, { | oField, x | TriggerUNM( oField , '2' )} )

    // Adiciona a field no modelo de dados
    oStruN9H:AddField( ;                        // Ord. Tipo Desc.
              STR0022, ;//Valor                 // [01] C Titulo do campo
              STR0022 ,;//Valor                 // [02] C Descrição do campo
              "TMP_VALOR", ;                    // [03] C identificador (ID) do
              TamSX3( "N9H_VLINDT" )[3]  , ;    // [04] C Tipo do campo
              TamSX3( "N9H_VLINDT" )[1] , ;     // [05] N Tamanho do campo
              TamSX3( "N9H_VLINDT" )[2] , ;     // [06] N Decimal do campo
              nil, ;                            // [07] B Code-block de validação do campo
              {|oField| WhenValor(oField)} , ;  // [08] B Code-block de WHEN
              {}, ;                             // [09] A Lista de valores permitido do campo combo
              .F. , ;                           // [10] L Indica se o campo tem preenchimento obrigatório
              {|oField| InitValor(oField) } , ; // [11] B Code-block de inicializacao do campo
              NIL    , ;                        // [12] L Indica se trata de um campo chave
              NIL , ;                           // [13] L Indica se o campo pode receber valor em uma operação de update.
              .T. )

    oStruN9H:AddField( ;                        // Ord. Tipo Desc.
              STR0044, ;//Valor                 // [01] C Titulo do campo
              STR0044 ,;//Valor                 // [02] C Descrição do campo
              "TMP_OBSERV", ;                   // [03] C identificador (ID) do
              TamSX3( "N9H_OBSERV" )[3]  , ;    // [04] C Tipo do campo
              TamSX3( "N9H_OBSERV" )[1] , ;     // [05] N Tamanho do campo
              TamSX3( "N9H_OBSERV" )[2] , ;     // [06] N Decimal do campo
              nil, ;                            // [07] B Code-block de validação do campo
              {|oField| WhenValor (oField)} , ; // [08] B Code-block de WHEN
              {}, ;                             // [09] A Lista de valores permitido do campo combo
              .F. , ;                           // [10] L Indica se o campo tem preenchimento obrigatório
              {|oField| InitObser(oField) } , ; // [11] B Code-block de inicializacao do campo
              NIL    , ;                        // [12] L Indica se trata de um campo chave
              NIL , ;                           // [13] L Indica se o campo pode receber valor em uma operação de update.
              .T. )
              
    oStruN9H:AddField( ;                        // Ord. Tipo Desc.
              STR0045, ;//Unid Medida                 // [01] C Titulo do campo
              STR0045 ,;//Unid Medida                 // [02] C Descrição do campo
              "TMP_UNIMED", ;                   // [03] C identificador (ID) do
              TamSX3( "N9H_UNIMED" )[3]  , ;    // [04] C Tipo do campo
              TamSX3( "N9H_UNIMED" )[1] , ;     // [05] N Tamanho do campo
              TamSX3( "N9H_UNIMED" )[2] , ;     // [06] N Decimal do campo
              {|oField| ValidUnMed(oField)}, ; // [07] B Code-block de validação do campo
              {|oField| WhenValor (oField)} , ; // [08] B Code-block de WHEN
              {}, ; // [09] A Lista de valores permitido do campo combo
              .F. , ;                           // [10] L Indica se o campo tem preenchimento obrigatório
              {|oField| InitUnMed(oField) } , ; // [11] B Code-block de inicializacao do campo
              NIL    , ;                        // [12] L Indica se trata de um campo chave
              NIL , ;                           // [13] L Indica se o campo pode receber valor em uma operação de update.
              .T. )

    oModel:AddFields( "OGAA580_N9H", , oStruN9H,/*bPre*/ ,/*bPost*/ ,/*bLoad*/ )
    oModel:AddGrid ( 'MODEL_GRID', 'OGAA580_N9H', oStruN9HGrd, , {|oModel| ValidLine(oModel)} , , ,)
    oModel:GetModel( 'MODEL_GRID'):SetUniqueLine( { 'N9H_TIPO'} )
    oModel:GetModel( "OGAA580_N9H" ):SetDescription( STR0001  ) //"Cadastro de  Indíces por Tabela"
    oModel:SetRelation( 'MODEL_GRID' , { { 'N9H_FILIAL' , 'xFilial( "N9H" )' } , { 'N9H_INDICE' , 'N9H_INDICE' }, { 'N9H_PROD' , 'N9H_PROD' }, { 'N9H_CODSAF' , 'N9H_CODSAF' }, { 'N9H_UFORIG' , 'N9H_UFORIG' }, { 'N9H_UFDEST' , 'N9H_UFDEST' }, { 'N9H_DTINVG' , 'N9H_DTINVG' }, { 'N9H_CODREG' , 'N9H_CODREG' } } , N9H->( IndexKey( 1 ) ) )
    oModel:SetPrimaryKey( { "N9H_FILIAL", "N9H_INDICE", "N9H_PROD", "N9H_CODSAF", "N9H_ITETAB", "N9H_UFORIG", "N9H_UFDEST", "N9H_DTINVG", "N9H_CODREG" } )
    oModel:GetModel("MODEL_GRID"):SetOptional(.T.)
    oModel:SetVldActivate(  { | oModel | oModel:GetModel("MODEL_GRID"):SetNoInsertLine(.F.), oModel:GetModel("MODEL_GRID"):SetNoUpdateLine(.F.), oModel:GetModel("MODEL_GRID"):SetNoDeleteLine(.F.), .T. })


  EndIf

  //-----------------------------
  // Instancia o modelo de dados
  //-----------------------------


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View MVC
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
  Local oStruN9H   := nil
  Local oStruN9HGr := nil
  Local oView    := FwFormView():New() // Instancia o modelo de dados
  Local oModel   := FwLoadModel( "OGAA580" )

  oView:SetModel( oModel )

  If FWIsInCallStack("OGAA580AAUX") .OR. FWIsInCallStack("OGAA580CPY")
    oStruN9HGr := FWFormStruct( 2, 'N9H', )
    oStruN9H   := FwFormStruct( 2, "N9H", {|cCampo| ALLTRIM(cCampo) $ "N9H_VLINDT|N9H_OBSERV|N9H_UNIMED" } )
    
    oStruN9H:SetProperty("N9H_UNIMED", MODEL_FIELD_VALID , {| x | ValidUMed( x ) }   )
    
    oStruN9HGr:SetProperty("N9H_PROD", MVC_VIEW_CANCHANGE , .F.)
    oStruN9HGr:SetProperty("N9H_CODSAF", MVC_VIEW_CANCHANGE , .F.)
    oStruN9HGr:SetProperty("N9H_INDICE", MVC_VIEW_CANCHANGE , .F.)
    oStruN9HGr:RemoveField("N9H_ITETAB")

    If _N9HExcl
      oStruN9HGr:AddField( ;                      // Ord. Tipo Desc.
                "N9H_FILIAL" , ;                  // [01] C Nome do Campo
                "01" , ;                          // [02] C Ordem
                STR0020, ; //Filial               // [03] C Titulo do campo
                STR0021, ; //Código da Filial     // [04] C Descrição do campo
                {}, ;                             // [05] A Array com Help
                TamSX3( "N9H_FILIAL" )[3]   , ;   // [06] C Tipo do campo
                PesqPict("N9H","N9H_FILIAL") , ;  // [07] C Picture
                NIL , ;                           // [08] B Bloco de Picture Var
                "" , ;                            // [09] C Consulta F3
                .F.    , ;                        // [10] L Indica se o campo é editável
                Nil , ;                           // [11] C Pasta do campo
                NIL , ;                           // [12] C Agrupamento do campo
                {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
                NIL   , ;                         // [14] N Tamanho Máximo da maior
                NIL , ;                           // [15] C Inicializador de Browse
                .T. , ;                           // [16] L Indica se o campo é virtual
                NIL )
    EndIf

    oStruN9HGr:AddGroup ( 'GRP_GRID', STR0023 , '' , 2 )  // "Dados para cópia"
    oStruN9HGr:SetProperty( "*"  , MVC_VIEW_GROUP_NUMBER , 'GRP_GRID' )
    oView:AddGrid  ( 'VIEW_GRID', oStruN9HGr, 'MODEL_GRID' )

    oStruN9H:AddGroup ( 'GRP_SUBST', STR0031 , '' , 2 )//"Dados para Substituição"

    MntStruct(@oStruN9H, "View")

    oStruN9H:RemoveField("N9H_VLINDT")
    oStruN9H:RemoveField("N9H_OBSERV")
    oStruN9H:RemoveField("N9H_UNIMED")

    oView:AddField ( 'VIEW_N9H',  oStruN9H,   'OGAA580_N9H' )

    oView:CreateHorizontalBox( 'TELA', 40 )
    oView:CreateHorizontalBox( 'GRID', 60 )   
    oView:SetOwnerView( 'VIEW_N9H', 'TELA' )
    oView:SetOwnerView( 'VIEW_GRID', 'GRID' )

    oView:SetViewProperty("VIEW_GRID", "GRIDFILTER")

    If FWIsInCallStack("OGAA580CPY")
      oView:SetDescription(STR0042) //"Cópia dos Índices por tabela"
    Else
      oView:SetDescription(STR0008) //"Alteração dos Índices por tabela"
    EndIf

  Else

    oStruN9H   := FwFormStruct( 2, "N9H", {|cCampo| !ALLTRIM(cCampo) $ "N9H_ITETAB|N9H_TIPO|N9H_DTIPO|N9H_VLINDT|N9H_OBSERV|N9H_UNIMED" } )
    oStruN9HGr := FWFormStruct( 2, 'N9H', {   |x| ALLTRIM(x) $ "N9H_ITETAB|N9H_TIPO|N9H_DTIPO|N9H_VLINDT|N9H_OBSERV|N9H_UNIMED"  }  )
    oStruN9HGr:RemoveField("N9H_ITETAB")
    oStruN9H:AddField( ;                          // Ord. Tipo Desc.
                "TMP_VALOR" , ;                   // [01] C Nome do Campo
                "12" , ;                          // [02] C Ordem
                STR0022, ; //Valor                // [03] C Titulo do campo
                STR0022, ; //Valor                // [04] C Descrição do campo
                {}, ;                             // [05] A Array com Help
                TamSX3( "N9H_VLINDT" )[3]   , ;   // [06] C Tipo do campo
                PesqPict("N9H","N9H_VLINDT") , ;  // [07] C Picture
                NIL , ;                           // [08] B Bloco de Picture Var
                "" , ;                            // [09] C Consulta F3
                .T.    , ;                        // [10] L Indica se o campo é editável
                Nil , ;                           // [11] C Pasta do campo
                NIL , ;                           // [12] C Agrupamento do campo
                {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
                NIL   , ;                         // [14] N Tamanho Máximo da maior
                NIL , ;                           // [15] C Inicializador de Browse
                .T. , ;                           // [16] L Indica se o campo é virtual
                NIL )
                
   oStruN9H:AddField( ;                          // Ord. Tipo Desc.
                "TMP_OBSERV" , ;                   // [01] C Nome do Campo
                "13" , ;                          // [02] C Ordem
                STR0044, ; //Valor                // [03] C Titulo do campo
                STR0044, ; //Valor                // [04] C Descrição do campo
                {}, ;                             // [05] A Array com Help
                TamSX3( "N9H_OBSERV" )[3]   , ;   // [06] C Tipo do campo
                PesqPict("N9H","N9H_OBSERV") , ;  // [07] C Picture
                NIL , ;                           // [08] B Bloco de Picture Var
                "" , ;                            // [09] C Consulta F3
                .T.    , ;                        // [10] L Indica se o campo é editável
                Nil , ;                           // [11] C Pasta do campo
                NIL , ;                           // [12] C Agrupamento do campo
                {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
                NIL   , ;                         // [14] N Tamanho Máximo da maior
                NIL , ;                           // [15] C Inicializador de Browse
                .T. , ;                           // [16] L Indica se o campo é virtual
                NIL )

    oStruN9H:AddField( ;                          // Ord. Tipo Desc.
                "TMP_UNIMED" , ;                   // [01] C Nome do Campo
                "13" , ;                          // [02] C Ordem
                STR0045, ; //Valor                // [03] C Titulo do campo
                STR0045, ; //Valor                // [04] C Descrição do campo
                {}, ;                             // [05] A Array com Help
                TamSX3( "N9H_UNIMED" )[3]   , ;   // [06] C Tipo do campo
                PesqPict("N9H","N9H_UNIMED") , ;  // [07] C Picture
                NIL , ;                           // [08] B Bloco de Picture Var
                "SAH", ;                          // [09] C Consulta F3
                .T.    , ;                        // [10] L Indica se o campo é editável
                Nil , ;                           // [11] C Pasta do campo
                NIL , ;                           // [12] C Agrupamento do campo
                {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
                NIL   , ;                         // [14] N Tamanho Máximo da maior
                NIL , ;                           // [15] C Inicializador de Browse
                .T. , ;                           // [16] L Indica se o campo é virtual
                NIL )

    oView:AddField( 'VIEW_N9H', oStruN9H, 'OGAA580_N9H' )
    oView:AddGrid ( 'VIEW_GRID', oStruN9HGr, 'MODEL_GRID' )
    oView:CreateHorizontalBox( 'TELA', 40 )
    oView:CreateHorizontalBox( 'GRID', 60 )
    oView:SetOwnerView( 'VIEW_N9H', 'TELA' )
    oView:SetOwnerView( 'VIEW_GRID', 'GRID' )
    oView:SetAfterViewActivate({|oView| AfterView(oView)})

  EndIf


Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
  Local aRotina := {}

  ADD OPTION aRotina Title STR0002  Action 'VIEWDEF.OGAA580'  OPERATION 2 ACCESS 0 // "Visualizar"
  ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.OGAA580'  OPERATION 3 ACCESS 0 // "Incluir"
  ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.OGAA580'  OPERATION 4 ACCESS 0 // "Alterar"
  ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.OGAA580'  OPERATION 5 ACCESS 0 // "Excluir"
  ADD OPTION aRotina Title STR0006  Action 'OGAA580AAUX()'    OPERATION 4 ACCESS 0 // "Alterar em Lote"
  ADD OPTION aRotina Title STR0007  Action 'OGAA580CPY()'     OPERATION 9 ACCESS 0 // "Copiar em Lote"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} TriggerVlr
Trigger do campo produto.
@author  rafael.voltz
@since   19/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function TriggerVlr(oField)
  Local cArea         := GetArea()
  Local oModel        := oField:GetModel()  
  Local oModelN9H     := oModel:getModel("OGAA580_N9H")
  Local oModelN9HGr   := oModel:getModel("MODEL_GRID")
  Local lDesativa     := .F.
  LOCAL nX            := 0

  /*Senao for algodao desativa grid e apaga registros*/
  If !AGRTPALGOD(oModelN9H:GetValue("N9H_PROD"))
    lDesativa := .T.
    oModelN9HGr:DelAllLine()
  Else
  	cUN := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9H:GetValue("N9H_INDICE"),"NK0_UM1PRO")
    If oModelN9HGr:Length() > 0
      If MsgYesNo(STR0009) //"Deseja carregar todos os tipos de algodão?"
        oModelN9HGr:SetNoInsertLine( lDesativa )
        oModelN9HGr:SetNoDeleteLine( lDesativa )
        oModelN9HGr:SetNoUpdateLine( lDesativa )

        DXA->(DbSetOrder(1))
        If DXA->(DBSeek(xFilial("DXA")))
          While DXA->(!Eof()) .And. DXA->DXA_FILIAL == xFilial("DXA")
            oModelN9HGR:SetValue("N9H_TIPO",  DXA->DXA_CODIGO)
            oModelN9HGR:SetValue("N9H_UNIMED", cUN)

            DXA->(dbSkip())

            If DXA->(!Eof()) .AND. DXA->DXA_FILIAL == xFilial("DXA")
              oModelN9HGR:AddLine()
              oModelN9HGR:GoLine(oModelN9HGR:Length())
            EndIf
          EndDo
        EndIf
      Else
        For nX := 1 To oModelN9HGr:Length()
          oModelN9HGr:Goline(nX)
          oModelN9HGr:UnDeleteLine()
        Next
      EndIf
    EndIf
    oModelN9H:LoadValue("TMP_VALOR", 0)
  EndIf

  oModelN9HGr:Goline(1)
  oModelN9HGr:SetNoInsertLine( lDesativa )
  oModelN9HGr:SetNoDeleteLine( lDesativa )
  oModelN9HGr:SetNoUpdateLine( lDesativa )  

  RestArea(cArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TriggerUNM
Trigger do campo índice
@author  tamyris.g	
@since   16/07/02018
@version version
/*/
//-------------------------------------------------------------------
Static Function TriggerUNM(oField, cOpc)
	Local cArea         := GetArea()
	Local oModel        := oField:GetModel()  
	Local oModelN9H     := oModel:getModel("OGAA580_N9H")
	Local oModelN9HGr   := oModel:getModel("MODEL_GRID")
	LOCAL nX            := 0
		 
	If cOpc = '1'
		cRetorno := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9H:GetValue("TMP_INDICE"),"NK0_UM1PRO")
	Else
	  	cRetorno := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9H:GetValue("N9H_INDICE"),"NK0_UM1PRO")
	  	
		/*Senao for algodao desativa grid e apaga registros*/
		If AGRTPALGOD(oModelN9H:GetValue("N9H_PROD"))
			If oModelN9HGr:Length() > 0
				For nX := 1 To oModelN9HGr:Length()
			      oModelN9HGr:Goline(nX)
			      oModelN9HGR:SetValue("N9H_UNIMED", cRetorno)
			    Next
		    EndIf
	    EndIf
    EndIF
	
    RestArea(cArea)
    
Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} PosModel
Funçao executada no pos model
@author  rafael.voltz
@since   19/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function PosModel(oModel)
  Local oModelN9H   := oModel:GetModel("OGAA580_N9H")
  Local oModelN9HGr := oModel:GetModel("MODEL_GRID")
  Local nX          := 0
  Local lVlrZero    := .F.
  Local cTipoZero   := ""

  If !FWIsInCallStack("OGAA580AAUX")  .AND. !FWIsInCallStack("OGAA580CPY")
    If !AGRTPALGOD(oModelN9H:GetValue("N9H_PROD"))
      oModelN9HGr:SetNoUpdateLine( .F. )
      oModelN9HGr:SetNoInsertLine( .F. )
      If oModelN9HGr:Length(.t.) == 0
        oModelN9HGr:addLine()
      EndIf
      iF oModel:GetOperation() != MODEL_OPERATION_DELETE
	      oModelN9HGr:SetValue("N9H_VLINDT", oModelN9H:GetValue("TMP_VALOR"))
	      oModelN9HGr:SetValue("N9H_OBSERV", oModelN9H:GetValue("TMP_OBSERV"))
	      oModelN9HGr:SetValue("N9H_UNIMED", oModelN9H:GetValue("TMP_UNIMED"))
      EndIF
    Else
      /* Se for algodao, e o array tiver mais de uma linha o tipo se torna
      obrigatorio para todas as linhas */
      If oModelN9HGr:Length(.T.) > 1
        For nX := 1 To oModelN9HGr:Length()
          oModelN9HGr:Goline(nX)
          If Empty(oModelN9HGr:GetValue("N9H_TIPO")) .AND. !oModelN9HGr:IsDeleted()
            MsgInfo(STR0011) //"Tipo não informado."
            Return .F.
          EndIf
          oModelN9HGr:Goline(1)
        Next
      EndIf
    EndIf
  EndIf

  For nX := 1 To oModelN9HGr:Length()
    oModelN9HGr:Goline(nX)
    If oModel:GetOperation() != MODEL_OPERATION_DELETE .AND.  oModel:GetOperation() != MODEL_OPERATION_UPDATE .and. !oModelN9HGr:IsDeleted()
      If FWIsInCallStack("OGAA580CPY")	
        If !VldDupl(oModelN9HGr:GetValue("N9H_INDICE"), oModelN9HGr:GetValue("N9H_PROD"), oModelN9HGr:GetValue("N9H_CODSAF"), oModelN9HGr:GetValue("N9H_TIPO"), oModelN9HGr:GetValue("N9H_DTINVG"), oModelN9HGr:GetValue("N9H_UFORIG"), oModelN9HGr:GetValue("N9H_UFDEST"), oModelN9HGr:GetValue("N9H_CODREG"), oModelN9HGr:GetValue("N9H_DTFNVG"))
          Return .F.
        EndIf
      Else 
        If !VldDupl(oModelN9H:GetValue("N9H_INDICE"), oModelN9H:GetValue("N9H_PROD"), oModelN9H:GetValue("N9H_CODSAF"), oModelN9HGr:GetValue("N9H_TIPO"), oModelN9H:GetValue("N9H_DTINVG"), oModelN9H:GetValue("N9H_UFORIG"), oModelN9H:GetValue("N9H_UFDEST"), oModelN9H:GetValue("N9H_CODREG"), oModelN9H:GetValue("N9H_DTFNVG"))
          Return .F.
        EndIf
      EndIf		

      If Empty(oModelN9HGr:GetValue("N9H_VLINDT"))
        lVlrZero  := .T.
        cTipoZero := oModelN9HGr:GetValue("N9H_TIPO")
      EndIf
    Endif    
  Next
  
  oModelN9HGr:Goline(1)

  If lVlrZero
    cMsg := STR0032 //"Existe valor de tabela não informado. Deseja continuar?"
    If cTipoZero != "  - " .AND. !empty(cTipoZero) 
      cMsg += CRLF + CRLF +  "Tipo: " + cTipoZero
    EndIf
    If !MsgYesNo( cMsg )
      Help( ,,STR0010,, STR0033, 1, 0,,,,,,{STR0034} ) //Ajuda" - "Confirmação não foi efetivada." - "Por favor, informe o valor da tabela."
      Return .F.
    EndIf
  EndIf

  	//Se está copiando ou alterando em lote busca o código do índice do "MODEL_GRID"
  If FWIsInCallStack("OGAA580AAUX") .OR. FWIsInCallStack("OGAA580CPY")
    If !fValPer1(oModel)
      Return .F.
    EndIf
  Else
    If !fValPer2(oModel)
      Return .F.
    EndIf
  EndIf

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} InitValor
Inicializa campo de valor quando produto for diferente de algodao.
@author  rafael.voltz
@since   19/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function InitValor(oField)
  Local oModel     := oField:GetModel()
  Local oModelN9H    := oModel:getModel("OGAA580_N9H")
  Local nValor       := 0

  If oModel:GetOperation() != MODEL_OPERATION_INSERT
    If !AGRTPALGOD(oModelN9H:GetValue("N9H_PROD"))
      nValor := N9H->N9H_VLINDT
    EndIf
  EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} InitObser
Inicializa campo de valor quando produto for diferente de algodao.
@author  tamyris.g
@since   31/05/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function InitObser(oField)
  Local oModel     := oField:GetModel()
  Local oModelN9H    := oModel:getModel("OGAA580_N9H")
  Local cValor       := ''

  If oModel:GetOperation() != MODEL_OPERATION_INSERT
    If !AGRTPALGOD(oModelN9H:GetValue("N9H_PROD"))
      cValor := N9H->N9H_OBSERV
    EndIf
  EndIf

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} InitUnMed
Inicializa campo de valor quando produto for diferente de algodao.
@author  tamyris.g
@since   31/05/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function InitUnMed(oField)
  Local oModel     := oField:GetModel()
  Local oModelN9H    := oModel:getModel("OGAA580_N9H")
  Local cValor       := ''

  If oModel:GetOperation() != MODEL_OPERATION_INSERT
    If !AGRTPALGOD(oModelN9H:GetValue("N9H_PROD"))
      cValor := N9H->N9H_UNIMED
    EndIf
  EndIf

Return cValor


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidUnMed
Validação Unidade de Medida
@author  tamyris.g
@since   31/05/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function ValidUnMed(oField)
  Local oModel     := oField:GetModel()
  Local oModelN9H    := oModel:getModel("OGAA580_N9H")
  Local lRet := .T.

  If !Empty(oModelN9H:GetValue("TMP_UNIMED")) 
	  lRet := ExistCpo("SAH", oModelN9H:GetValue("TMP_UNIMED"), 1 )
  EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WhenValor
When do campo Valor. Habilita campo quando o produto nao for algodao
@author  rafael.voltz
@since   19/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function WhenValor(oField)
  Local oModel     := oField:GetModel()
  Local oModelN9H    := oModel:getModel("OGAA580_N9H")

  If AGRTPALGOD(oModelN9H:GetValue("N9H_PROD"))
    Return .F.
  EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterView
Funcao de execucao após ativar a view
@author  rafael.voltz
@since   19/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function  AfterView(oView)
  Local oModel  := oView:GetModel()
  Local oModelN9H    := oModel:getModel("OGAA580_N9H")
  Local oModelN9HGr  := oModel:getModel("MODEL_GRID")

  If oModel:GetOperation() != MODEL_OPERATION_INSERT .and. oModel:GetOperation() != MODEL_OPERATION_DELETE
  
    If !AGRTPALGOD(oModelN9H:GetValue("N9H_PROD")) 
      oModelN9HGr:LoadValue("N9H_VLINDT", 0)
      oModelN9HGr:LoadValue("N9H_OBSERV", '')
      oModelN9HGr:LoadValue("N9H_UNIMED", '')
      oModel:GetModel( 'MODEL_GRID' ):SetNoInsertLine( .T. )
      oModel:GetModel( 'MODEL_GRID' ):SetNoDeleteLine( .T. )
      oModel:GetModel( 'MODEL_GRID' ):SetNoUpdateLine( .T. )
    Else
      oModel:GetModel( 'MODEL_GRID' ):SetNoInsertLine( .T. )
      oModel:GetModel( 'MODEL_GRID' ):SetNoDeleteLine( .T. )
    EndIf    
  Else
    oModel:GetModel( 'MODEL_GRID' ):SetNoInsertLine( .F. )
    oModel:GetModel( 'MODEL_GRID' ):SetNoDeleteLine( .F. )
  EndIf
 
  If !FWIsInCallStack("OGAA580AAUX") .and. !FWIsInCallStack("OGAA580CPY")
    oView:GetViewObj("VIEW_GRID")[3]:oBrowse:oFwFilter:CleanFilter()
    oView:GetViewObj("VIEW_GRID")[3]:oBrowse:oFwFilter:ExecuteFilter()
  EndIf

  oView:Refresh()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeLine

@author  rafael.voltz
@since   21/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function ValidLine(oModel)
  Local oModel    := oModel:GetModel()
  Local oModelN9HGr := oModel:GetModel('MODEL_GRID')

  If oModelN9HGr:Length(.t.) > 1    
    If Empty(Alltrim(oModelN9HGr:GetValue("N9H_TIPO")))
      Help( ,,STR0010,, STR0011, 1, 0,,,,,,{STR0012} )//"Ajuda" - "Tipo não informado." - "Para adicionar uma nova linha é necessário informar o tipo."
      Return .F.
    EndIf    
  EndIf
  
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA580AAUX
Alteração em lote
@author  rafael.voltz
@since   21/04/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGAA580AAUX()
  Local lPerg := .F.

  If _N9HExcl //exclusivo
    lPerg := Pergunte("OGAA580B")
  Else
    lPerg := Pergunte("OGAA580")
  EndIf

  If lPerg
    FWExecView('', 'VIEWDEF.OGAA580', MODEL_OPERATION_UPDATE, , {|| .T. }) //executado para refazer a view - reload da estrutura de campos
  EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA580CPY
Função de cópia
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function OGAA580CPY()
  Local lPerg := .F.

  _lCopy := .T.

  If _N9HExcl //exclusivo
    lPerg := Pergunte("OGAA580B")
  Else
    lPerg := Pergunte("OGAA580")
  EndIf

  If lPerg
    FWExecView('', 'VIEWDEF.OGAA580', 9, , {|| .T. }) //executado para refazer a view - reload da estrutura de campos
  EndIf

  _lCopy := .F.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ActivateMD
Ativação do model
@author  rafael.voltz
@since   21/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function ActivateMD(oModel, nOperation)
  Local oModelN9HGR := oModel:GetModel( "MODEL_GRID" )
  Local oStruN9H    := FWFormStruct( 1, "N9H" )
  Local nA          := 0
  Local lRet        := .F.
  Local lConsVlr    := .F.
  Local aArea       := GetArea()

  Private cAliasQry   := GetNextAlias()

  cAliasQry := BuscaDados()

  If _lCopy
    lConsVlr := MsgYesNo(STR0035) //"Considerar o valor da tabela na cópia?"
  EndIf

  oModelN9HGR:SetNoInsertLine( .F. )

  While (cAliasQry)->(!Eof())
    lRet := .T.
    For nA:=1 to Len(oStruN9H:aFields)
      if (!oStruN9H:GetProperty(oStruN9H:aFields[nA][3], MODEL_FIELD_VIRTUAL) .OR. oStruN9H:aFields[nA][3] == "N9H_FILIAL") .and. oStruN9H:GetProperty(oStruN9H:aFields[nA][3], MODEL_FIELD_TIPO) <> "M" .and. !empty(&("( cAliasQry )->"+oStruN9H:aFields[nA][3]))
        if !empty(&("( cAliasQry )->"+oStruN9H:aFields[nA][3]))
          If _lCopy .AND. !lConsVlr .AND. oStruN9H:aFields[nA][3] == "N9H_VLINDT"
            oModelN9HGR:LoadValue(oStruN9H:aFields[nA][3],  0)
          Else
            oModelN9HGR:LoadValue(oStruN9H:aFields[nA][3],  IIF(oStruN9H:GetProperty(oStruN9H:aFields[nA][3], MODEL_FIELD_TIPO) <> "D", &("( cAliasQry )->"+oStruN9H:aFields[nA][3]), StoD(&("( cAliasQry )->"+oStruN9H:aFields[nA][3]))))
          EndIf

          If oStruN9H:aFields[nA][3] == "N9H_PROD"
              oModelN9HGR:LoadValue("N9H_DPROD", POSICIONE("SB1",1,XFILIAL("SB1")+oModelN9HGR:GetValue("N9H_PROD"),"B1_DESC"))
          EndIf

          If oStruN9H:aFields[nA][3] == "N9H_TIPO"
              oModelN9HGR:LoadValue("N9H_DTIPO", POSICIONE("DXA",1,XFILIAL("DXA")+oModelN9HGR:GetValue("N9H_TIPO"),"DXA_DESCRI"))
          EndIf
          
          If oStruN9H:aFields[nA][3] == "N9H_CODREG"
              oModelN9HGR:LoadValue("N9H_DESREG", POSICIONE("NBQ",1,XFILIAL("NBQ")+oModelN9HGR:GetValue("N9H_CODREG"),"NBQ_DESREG"))
          EndIf
        endif
      endif
    next

    (cAliasQry)->(dbSkip())

    If ( cAliasQry )->( !Eof() )
      oModelN9HGR:AddLine()
      oModelN9HGR:GoLine(oModelN9HGR:Length())
    EndIf
  EndDo

  oModelN9HGR:GoLine(1)
  oModelN9HGR:SetNoInsertLine( .T. )

  (cAliasQry)->(dbCloseArea())

  RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldActveMd
Validação antes de ativar o model
@author  rafael.voltz
@since   21/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function VldActveMd(oModel, nOperation)
  Local lRet      := .F.
  Private cAliasQry   := GetNextAlias()

  cAliasQry := BuscaDados()

  While (cAliasQry)->(!Eof())
    lRet := .T.
    exit
  EndDo

  IF !lRet
    Help( ,,STR0010,, STR0013, 1, 0,,,,,,{STR0014} ) //"Ajuda" -"Não foram encontrados para alteração." - "Por favor, verifique os dados informados no filtro."
  EndIf
  (cAliasQry)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaDados
Filtra os dados nas funções de cópia e alteração em lote
@author  rafael.voltz
@since   21/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function BuscaDados()
  Local cFiltro     := ""
  Local cFilIni     := ""
  Local cFilFim     := ""
  Local cIndice     := ""
  Local cSafra      := ""
  Local cProdIni    := ""
  Local cProdFim    := ""
  Local cTipoIni    := ""
  Local cTipoFim    := ""
  Local cUfOrigIni  := ""
  Local cUfOrigFim  := ""
  Local cUfDestIni  := ""
  Local cUfDestFim  := ""
  Local cDtVigIni   := ""
  Local cDtVigFim   := ""
  Local cDtFnVgDe   := ""
  Local cDtFnVgAte  := ""
  Local cRegiaoIni  := ""
  Local cRegiaoFim  := ""

  If _N9HExcl //exclusivo

    cFilIni    := MV_PAR01
    cFilFim    := MV_PAR02
    cIndice    := MV_PAR03
    cSafra     := MV_PAR04
    cProdIni   := MV_PAR05
    cProdFim   := MV_PAR06
    cTipoIni   := MV_PAR07
    cTipoFim   := MV_PAR08
    If !Empty(MV_PAR09)
      cDtVigIni := dtos(MV_PAR09) //Ini. Vigência De?
    EndIf
    If !Empty(MV_PAR10)
      cDtVigFim := dtos(MV_PAR10) //Ini. Vigência Até? 
    EndIf
    If !Empty(MV_PAR11)
      cDtFnVgDe := dtos(MV_PAR11) //Fin. Vigência De?
    EndIf
    If !Empty(MV_PAR12)
      cDtFnVgAte := dtos(MV_PAR12)//Fin. Vigência Até?
    EndIf
    cUfOrigIni := MV_PAR13
    cUfOrigFim := MV_PAR14
    cUfDestIni := MV_PAR15
    cUfDestFim := MV_PAR16
    cRegiaoIni := MV_PAR17
    cRegiaoFim := MV_PAR18

    cFiltro := " N9H_FILIAL   BETWEEN '" + cFilIni +  "' AND '" + cFilFim + "'" //FILIAL
  Else

    cIndice  := MV_PAR01
    cSafra   := MV_PAR02
    cProdIni := MV_PAR03
    cProdFim := MV_PAR04
    cTipoIni := MV_PAR05
    cTipoFim := MV_PAR06
    If !Empty(MV_PAR07)
      cDtVigIni := dtos(MV_PAR07) //Ini. Vigência De?
    EndIf
    If !Empty(MV_PAR08)
      cDtVigFim := dtos(MV_PAR08) //Ini. Vigência Até? 
    EndIf
    If !Empty(MV_PAR09)
      cDtFnVgDe := dtos(MV_PAR09) //Fin. Vigência De?
    EndIf
    If !Empty(MV_PAR10)
      cDtFnVgAte := dtos(MV_PAR10)//Fin. Vigência Até?
    EndIf
    cUfOrigIni := MV_PAR11
    cUfOrigFim := MV_PAR12
    cUfDestIni := MV_PAR13
    cUfDestFim := MV_PAR14
    cRegiaoIni := MV_PAR15
    cRegiaoFim := MV_PAR16

    cFiltro := " N9H_FILIAL = '" + xFilial("N9H") + "'" //FILIAL
  EndIf

  If cTipoIni = "  - "
    cTipoIni := ""
  Endif
  
  If cTipoFim = "  - "
    cTipoFim := "99-9"
  Endif

  IIF(!Empty(cIndice), cFiltro += "AND N9H_INDICE = '" + cIndice + "'", nil) //Indice
  IIF(!Empty(cSafra), cFiltro += "AND N9H_CODSAF = '" + cSafra + "'", nil) //Safra
  
  If !Empty(cDtVigIni) .and. !Empty(cDtVigFim)
    cFiltro += " AND (N9H_DTINVG BETWEEN '" + cDtVigIni + "' AND '" + cDtVigFim + "') " //DATA VIGÊNCIA
  EndIf

  If !Empty(cDtFnVgDe) .and. !Empty(cDtFnVgAte)
    cFiltro += " AND (N9H_DTFNVG BETWEEN '" + cDtFnVgDe + "' AND '" + cDtFnVgAte + "') " //DATA FINAL VIGÊNCIA
  EndIf

  cFiltro += " AND (N9H_PROD   BETWEEN '" + cProdIni + "' AND '" + cProdFim + "') " //PRODUTO
  cFiltro += " AND (  (B5_TPCOMMO = '2' AND N9H_TIPO   BETWEEN '" + cTipoIni + "' AND '" + cTipoFim + "') OR (B5_TPCOMMO <> '2')  ) " //TIPO, se produto for ALGODAO(B5_TPCOMMO = '2') faz por tipo, se GRÃOS(B5_TPCOMMO <> '2') não usa o tipo
  cFiltro += " AND (N9H_UFORIG BETWEEN '" + cUfOrigIni +"' AND '" + cUfOrigFim + "') " //UF ORIGEM
  cFiltro += " AND (N9H_UFDEST BETWEEN '" + cUfDestIni +"' AND '" + cUfDestFim + "') " //UF DESTINO
  cFiltro += " AND (N9H_CODREG BETWEEN '" + cRegiaoIni +"' AND '" + cRegiaoFim + "') " //REGIAO

  cFiltro := "%"+cFiltro+"%"

  BeginSQL Alias cAliasQry
    SELECT *
      FROM %table:N9H% N9H
      INNER JOIN %table:SB5% SB5 ON  B5_COD = N9H_PROD AND SB5.%notdel%
     WHERE  %Exp:cFiltro%
       AND N9H.%notdel%
  EndSql

Return cAliasQry

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Função para salvar os dados do model
@author  rafael.voltz
@since   21/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

  Local oModelN9HGr := oModel:GetModel("MODEL_GRID")
  Local nX          := 0
  Local cFilBkp     := ""
  Local nSaveSx8    := GetSX8Len()
  Local aArea       := GetArea()
  Local aInd        := {}

  If FWIsInCallStack("OGAA580AAUX")

    BEGIN TRANSACTION
      N9H->(DbSetOrder(1)) //N9H_FILIAL+N9H_INDICE+N9H_PROD+N9H_CODSAF+N9H_ITETAB
      For nX = 1 To oModelN9HGr:Length()
        oModelN9HGr:Goline(nX)

        IF _N9HExcl
          cFilBkp := oModelN9HGr:GetValue("N9H_FILIAL")
        Else
          cFilBkp := xFilial("N9H")
        EndIf

        If N9H->(DbSeek(cFilBkp + oModelN9HGr:GetValue("N9H_INDICE") + oModelN9HGr:GetValue("N9H_PROD") + oModelN9HGr:GetValue("N9H_CODSAF") + oModelN9HGr:GetValue("N9H_ITETAB")))
          RecLock("N9H",.F.)
          N9H->N9H_TIPO   := oModelN9HGr:GetValue("N9H_TIPO")
          N9H->N9H_UFORIG := oModelN9HGr:GetValue("N9H_UFORIG")
          N9H->N9H_UFDEST := oModelN9HGr:GetValue("N9H_UFDEST")
          N9H->N9H_DTINVG := oModelN9HGr:GetValue("N9H_DTINVG")
          N9H->N9H_DTFNVG := oModelN9HGr:GetValue("N9H_DTFNVG")
          N9H->N9H_VLINDT := oModelN9HGr:GetValue("N9H_VLINDT")
          N9H->N9H_OBSERV := oModelN9HGr:GetValue("N9H_OBSERV")
          N9H->N9H_UNIMED := oModelN9HGr:GetValue("N9H_UNIMED")
          N9H->N9H_CODREG := oModelN9HGr:GetValue("N9H_CODREG")
          N9H->(MsUnlock())	

          If oModelN9HGr:IsModified()
            cChave := N9H->(N9H_FILIAL+N9H_CODSAF+N9H_PROD+N9H_ITETAB)

            nPos   := aScan( aInd, { |x| AllTrim( x[5] ) == AllTrim(cChave) } )

            If nPos == 0
              aAdd(aInd, {N9H->N9H_FILIAL, N9H->N9H_CODSAF, N9H->N9H_PROD, N9H->N9H_ITETAB, cChave})
            EndIf
          EndIf

        EndIf
      Next

    END TRANSACTION

  ElseIf FWIsInCallStack("OGAA580CPY")

    BEGIN TRANSACTION 

      /* Na cópia em lote, se encontrar registros com a mesma filial, índice, produto e safra, 
         altera a data de final de vigência para a data atal. */
      fAjusDtFin(oModel)

      For nX = 1 To oModelN9HGr:Length()
        oModelN9HGr:Goline(nX)

        IF _N9HExcl
          cFilBkp := oModelN9HGr:GetValue("N9H_FILIAL")
        Else
          cFilBkp := xFilial("N9H")
        EndIf

        RecLock("N9H",.T.)
        N9H->N9H_FILIAL := cFilBkp
        N9H->N9H_INDICE := oModelN9HGr:GetValue("N9H_INDICE")
        N9H->N9H_CODSAF := oModelN9HGr:GetValue("N9H_CODSAF")
        N9H->N9H_PROD   := oModelN9HGr:GetValue("N9H_PROD")
        N9H->N9H_TIPO   := oModelN9HGr:GetValue("N9H_TIPO")
        N9H->N9H_UFORIG := oModelN9HGr:GetValue("N9H_UFORIG")
        N9H->N9H_UFDEST := oModelN9HGr:GetValue("N9H_UFDEST")
        N9H->N9H_DTINVG := oModelN9HGr:GetValue("N9H_DTINVG")
        N9H->N9H_DTFNVG := oModelN9HGr:GetValue("N9H_DTFNVG")
        N9H->N9H_VLINDT := oModelN9HGr:GetValue("N9H_VLINDT")
        N9H->N9H_OBSERV := oModelN9HGr:GetValue("N9H_OBSERV")
        N9H->N9H_UNIMED := oModelN9HGr:GetValue("N9H_UNIMED")
        N9H->N9H_CODREG := oModelN9HGr:GetValue("N9H_CODREG")
        N9H->N9H_ITETAB := GetSXENum('N9H','N9H_ITETAB')
        N9H->(MsUnlock())	

        If oModelN9HGr:IsModified()
          cChave := N9H->(N9H_FILIAL+N9H_CODSAF+N9H_PROD+N9H_ITETAB)

          nPos   := aScan( aInd, { |x| AllTrim( x[5] ) == AllTrim(cChave) } )

          If nPos == 0
            aAdd(aInd, {N9H->N9H_FILIAL, N9H->N9H_CODSAF, N9H->N9H_PROD, N9H->N9H_ITETAB, cChave})
          EndIf
        EndIf
      Next

    END TRANSACTION
  Else

    FwFormCommit(oModel)

  EndIf
  
  While (GetSX8Len() > nSaveSx8)
    ConfirmSX8()
  EndDo

  if !Empty(aInd)
      fAtuPrRec(aInd)
  EndIf

  RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA580VLTP
Validação do tipo
@author  rafael.voltz
@since   23/04/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGAA580VLTP(cTipoIni, cTipoFim)

  If Empty(cTipoFim)
    Help(" ",1,"ATEINVALID")
    Return .f.
  Elseif cTipoFim < cTipoIni
    Help(" ",1,"DEATEINVAL")
    Return .f.
  Endif

  If cTipoFim = '99-9'
    Return .t.
  ElseIf !ExistCpo("DXA",cTipoFim)
    Return .f.
  Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA580VLFIL
Função de validação da filial
@author  rafael.voltz
@since   23/04/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGAA580VLFIL(cFilIni, cFilFim, nCmp)

  If nCmp == 2
    If Empty(cFilFim)
      Help(" ",1,"ATEINVALID")
      Return .f.
    Elseif cFilFim < cFilIni
      Help(" ",1,"DEATEINVAL")
      Return .f.
    Endif

    If cFilFim = replicate('Z',Len(cFilFim))
      Return .t.
    ElseIf !FWFilExist(cEmpAnt, cFilFim)
      Msginfo(STR0015) // Filial não cadastrada.
      Return .f.
    EndIf
  Else
    If !FWFilExist(cEmpAnt, cFilIni)
      Msginfo(STR0015) // Filial não cadastrada.
      Return .F.
    EndIf
  Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSubst
Função para substituir os dados em tela.
@author  rafael.voltz
@since   24/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function VldSubst(oField)
  Local oModel    := oField:getModel()
  Local oModelN9H   := oModel:GetModel("OGAA580_N9H")
  Local oModelN9HGr := oModel:GetModel("MODEL_GRID")
  Local nX          := 0
  Local oView       := FwViewActive()
  Local aLinesFil   := oView:GetViewObj("VIEW_GRID")[3]:GetFilLines()

  If oModelN9H:GetValue("TMP_SUBST") == .T.
    If MsgYesNo(STR0023) //"Deseja  realizar substituição dos dados informados para todos que estão listados abaixo? "
      For nX := 1 to oModelN9HGr:Length()
        oModelN9HGr:GoLine(nX)

        If aScan(aLinesFil, {|x| x == nX}) > 0
          If _lCopy
            If !Empty(oModelN9H:GetValue("TMP_INDICE"))
              oModelN9HGr:LoadValue("N9H_INDICE", oModelN9H:GetValue("TMP_INDICE"))
            EndIf


            If !Empty(oModelN9H:GetValue("TMP_CODSAF"))
              oModelN9HGr:LoadValue("N9H_CODSAF", oModelN9H:GetValue("TMP_CODSAF"))
            EndIf

            If !Empty(oModelN9H:GetValue("TMP_DTINVG"))
              dtVigen := oModelN9H:GetValue("TMP_DTINVG")
              oModelN9HGr:LoadValue("N9H_DTINVG", oModelN9H:GetValue("TMP_DTINVG"))
            EndIf

            If !Empty(oModelN9H:GetValue("TMP_DTFNVG"))
              oModelN9HGr:LoadValue("N9H_DTFNVG", oModelN9H:GetValue("TMP_DTFNVG"))
            EndIf
          EndIf

          If (oModelN9H:GetValue("TMP_VLINDT")) > 0
            oModelN9HGr:LoadValue("N9H_VLINDT", oModelN9H:GetValue("TMP_VLINDT"))
          EndIf
          
          If !Empty((oModelN9H:GetValue("TMP_OBSERV")) )
            oModelN9HGr:LoadValue("N9H_OBSERV", oModelN9H:GetValue("TMP_OBSERV"))
          EndIf
          
          If !Empty((oModelN9H:GetValue("TMP_UNIMED")) )
            oModelN9HGr:LoadValue("N9H_UNIMED", oModelN9H:GetValue("TMP_UNIMED"))
          EndIf
        EndIf
      Next nX
      oModelN9HGr:GoLine(1)

      If _lCopy
        oModelN9H:ClearField("TMP_INDICE")
        oModelN9H:ClearField("TMP_CODSAF")
        oModelN9H:ClearField("TMP_DTINVG")
        oModelN9H:ClearField("TMP_DTFNVG")
      EndIf

      oModelN9H:ClearField("TMP_VLINDT")
      oModelN9H:ClearField("TMP_SUBST")

      MsgInfo(STR0024) //"Dados substituídos  com sucesso. Somente após a confirmação eles serão confirmados."

      oView:Refresh()
    EndIf
  EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MntStruct
Estrutura dos campos virtuais da cópia
@author  rafael.voltz
@since   23/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function MntStruct(oStruN9H, cTipStruct)

  If cTipStruct == "Model"
  	If _lCopy
    	oStruN9H:AddField( ; // Ord. Tipo Desc.
    	        STR0025, ; //"Índice"           // [01] C Titulo do campo
    	        STR0025 ,; //"Índice"           // [02] C Descrição do campo
    	        "TMP_INDICE", ;                 // [03] C identificador (ID) do
    	        TamSX3( "N9H_INDICE" )[3]  , ;  // [04] C Tipo do campo
    	        TamSX3( "N9H_INDICE" )[1] , ;   // [05] N Tamanho do campo
    	        TamSX3( "N9H_INDICE" )[2] , ;   // [06] N Decimal do campo
    	        {|| VldIndice()}, ;         // [07] B Code-block de validação do campo
    	        nil, ;                          // [08] B Code-block de WHEN
    	        {}, ;                           // [09] A Lista de valores permitido do campo combo
    	        .F. , ;                         // [10] L Indica se o campo tem preenchimento obrigatório
    	        nil , ;                         // [11] B Code-block de inicializacao do campo
    	        NIL    , ;                      // [12] L Indica se trata de um campo chave
    	        NIL , ;                         // [13] L Indica se o campo pode receber valor em uma operação de update.
    	        .T. )
    	
    	oStruN9H:AddField( ; // Ord. Tipo Desc.
    	        STR0026, ; //Safra              // [01] C Titulo do campo
    	        STR0026, ; //Safra              // [02] C Descrição do campo
    	        "TMP_CODSAF", ;                 // [03] C identificador (ID) do
    	        TamSX3( "N9H_CODSAF" )[3]  , ;  // [04] C Tipo do campo
    	        TamSX3( "N9H_CODSAF" )[1] , ;   // [05] N Tamanho do campo
    	        TamSX3( "N9H_CODSAF" )[2] , ;   // [06] N Decimal do campo
    	        {|| VldSafra()}, ;         // [07] B Code-block de validação do campo
    	        nil, ;                          // [08] B Code-block de WHEN
    	        {},  ;                          // [09] A Lista de valores permitido do campo combo
    	        .F., ;                          // [10] L Indica se o campo tem preenchimento obrigatório
    	        nil, ;                          // [11] B Code-block de inicializacao do campo
    	        NIL, ;                          // [12] L Indica se trata de um campo chave
    	        NIL, ;                          // [13] L Indica se o campo pode receber valor em uma operação de update.
    	        .T. )
    
      oStruN9H:AddField( ; // Ord. Tipo Desc.
              STR0027, ; //"Dt Vigência"      // [01] C Titulo do campo
              STR0027, ; //"Dt Vigência"      // [02] C Descrição do campo
              "TMP_DTINVG", ;                 // [03] C identificador (ID) do
              TamSX3( "N9H_DTINVG" )[3]  , ;  // [04] C Tipo do campo
              TamSX3( "N9H_DTINVG" )[1] , ;   // [05] N Tamanho do campo
              TamSX3( "N9H_DTINVG" )[2] , ;   // [06] N Decimal do campo
              nil, ;                          // [07] B Code-block de validação do campo
              nil, ;                          // [08] B Code-block de WHEN
              {}, ;                           // [09] A Lista de valores permitido do campo combo
              .F. , ;                         // [10] L Indica se o campo tem preenchimento obrigatório
              nil , ;                         // [11] B Code-block de inicializacao do campo
              NIL    , ;                      // [12] L Indica se trata de um campo chave
              NIL , ;                         // [13] L Indica se o campo pode receber valor em uma operação de update.
              .T. )

       oStruN9H:AddField( ; // Ord. Tipo Desc.
              STR0050, ;    //"Dt. Fin. Vig." // [01] C Titulo do campo
              STR0050, ;    //"Dt. Fin. Vig." // [02] C Descrição do campo
              "TMP_DTFNVG", ;                 // [03] C identificador (ID) do
              TamSX3( "N9H_DTFNVG" )[3] , ;   // [04] C Tipo do campo
              TamSX3( "N9H_DTFNVG" )[1] , ;   // [05] N Tamanho do campo
              TamSX3( "N9H_DTFNVG" )[2] , ;   // [06] N Decimal do campo
              nil, ;                          // [07] B Code-block de validação do campo
              nil, ;                          // [08] B Code-block de WHEN
              {}, ;                           // [09] A Lista de valores permitido do campo combo
              .F. , ;                         // [10] L Indica se o campo tem preenchimento obrigatório
              nil , ;                         // [11] B Code-block de inicializacao do campo
              NIL    , ;                      // [12] L Indica se trata de um campo chave
              NIL , ;                         // [13] L Indica se o campo pode receber valor em uma operação de update.
              .T. )
    Endif 

    oStruN9H:AddField( ;                    // Ord. Tipo Desc.
            STR0022, ; //Valor              // [01] C Titulo do campo
            STR0022 ,; //Valor              // [02] C Descrição do campo
            "TMP_VLINDT", ;                 // [03] C identificador (ID) do
            TamSX3( "N9H_VLINDT" )[3]  , ;  // [04] C Tipo do campo
            TamSX3( "N9H_VLINDT" )[1] , ;   // [05] N Tamanho do campo
            TamSX3( "N9H_VLINDT" )[2] , ;   // [06] N Decimal do campo
            nil, ;                          // [07] B Code-block de validação do campo
            nil, ;                          // [08] B Code-block de WHEN
            {}, ;                           // [09] A Lista de valores permitido do campo combo
            .F. , ;                         // [10] L Indica se o campo tem preenchimento obrigatório
            nil , ;                         // [11] B Code-block de inicializacao do campo
            NIL    , ;                      // [12] L Indica se trata de um campo chave
            NIL , ;                         // [13] L Indica se o campo pode receber valor em uma operação de update.
            .T. )
            
     oStruN9H:AddField( ;                    // Ord. Tipo Desc.
            STR0044, ; //Observação              // [01] C Titulo do campo
            STR0044 ,; //Observação              // [02] C Descrição do campo
            "TMP_OBSERV", ;                 // [03] C identificador (ID) do
            TamSX3( "N9H_OBSERV" )[3]  , ;  // [04] C Tipo do campo
            TamSX3( "N9H_OBSERV" )[1] , ;   // [05] N Tamanho do campo
            TamSX3( "N9H_OBSERV" )[2] , ;   // [06] N Decimal do campo
            nil, ;                          // [07] B Code-block de validação do campo
            nil, ;                          // [08] B Code-block de WHEN
            {}, ;                           // [09] A Lista de valores permitido do campo combo
            .F. , ;                         // [10] L Indica se o campo tem preenchimento obrigatório
            nil , ;                         // [11] B Code-block de inicializacao do campo
            NIL    , ;                      // [12] L Indica se trata de um campo chave
            NIL , ;                         // [13] L Indica se o campo pode receber valor em uma operação de update.
            .T. )
            
     oStruN9H:AddField( ;                    // Ord. Tipo Desc.
            STR0045, ; //Unid Medida              // [01] C Titulo do campo
            STR0045 ,; //Unid Medida              // [02] C Descrição do campo
            "TMP_UNIMED", ;                 // [03] C identificador (ID) do
            TamSX3( "N9H_UNIMED" )[3]  , ;  // [04] C Tipo do campo
            TamSX3( "N9H_UNIMED" )[1] , ;   // [05] N Tamanho do campo
            TamSX3( "N9H_UNIMED" )[2] , ;   // [06] N Decimal do campo
            {|oField| ValidUnMed(oField)}, ; // [07] B Code-block de validação do campo
            nil, ;                          // [08] B Code-block de WHEN
            {}, ;                           // [09] A Lista de valores permitido do campo combo
            .F. , ;                         // [10] L Indica se o campo tem preenchimento obrigatório
            nil , ;                         // [11] B Code-block de inicializacao do campo
            NIL    , ;                      // [12] L Indica se trata de um campo chave
            NIL , ;                         // [13] L Indica se o campo pode receber valor em uma operação de update.
            .T. )
    
    oStruN9H:AddField( ; // Ord. Tipo Desc.
            STR0028, ; //"Substituir?"        // [01] C Titulo do campo
            STR0029, ; //"Substituir campos"  // [02] C Descrição do campo
            "TMP_SUBST", ;                    // [03] C identificador (ID) do
            "L" , ;                           // [04] C Tipo do campo
            1, ;                              // [05] N Tamanho do campo
            0 , ;                             // [06] N Decimal do campo
            {|oField| VldSubst(oField)}, ;    // [07] B Code-block de validação do campo
            nil, ;                            // [08] B Code-block de WHEN
            {}, ;                             // [09] A Lista de valores permitido do campo combo
            .F. , ;                           // [10] L Indica se o campo tem preenchimento obrigatório
            nil , ;                           // [11] B Code-block de inicializacao do campo
            NIL    , ;                        // [12] L Indica se trata de um campo chave
            NIL , ;                           // [13] L Indica se o campo pode receber valor em uma operação de update.
            .T. )
  Else
    If _lCopy
      oStruN9H:AddField( ;                      // Ord. Tipo Desc.
            "TMP_INDICE" , ;                  // [01] C Nome do Campo
            "01" , ;                          // [02] C Ordem
            STR0025, ; //"Índice"             // [03] C Titulo do campo
            STR0025, ; //"Índice"             // [04] C Descrição do campo
            {}, ;                             // [05] A Array com Help
            TamSX3( "N9H_INDICE" )[3]   , ;   // [06] C Tipo do campo
            PesqPict("N9H","N9H_INDICE") , ;  // [07] C Picture
            NIL , ;                           // [08] B Bloco de Picture Var
            "NK0" , ;                         // [09] C Consulta F3
            .T.    , ;                        // [10] L Indica se o campo é editável
            Nil , ;                           // [11] C Pasta do campo
            NIL , ;                           // [12] C Agrupamento do campo
            {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
            NIL   , ;                         // [14] N Tamanho Máximo da maior
            NIL , ;                           // [15] C Inicializador de Browse
            .T. , ;                           // [16] L Indica se o campo é virtual
            NIL )

      oStruN9H:AddField( ;                      // Ord. Tipo Desc.
              "TMP_CODSAF" , ;                  // [01] C Nome do Campo
              "02" , ;                          // [02] C Ordem
              STR0026, ; //"Safra"              // [03] C Titulo do campo
              STR0026, ; //"Safra"              // [04] C Descrição do campo
              {}, ;                             // [05] A Array com Help
              TamSX3( "N9H_CODSAF" )[3]   , ;   // [06] C Tipo do campo
              PesqPict("N9H","N9H_CODSAF") , ;  // [07] C Picture
              NIL , ;                           // [08] B Bloco de Picture Var
              "NJU" , ;                           // [09] C Consulta F3
              .T.    , ;                        // [10] L Indica se o campo é editável
              Nil , ;                           // [11] C Pasta do campo
              NIL , ;                           // [12] C Agrupamento do campo
              {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
              NIL   , ;                         // [14] N Tamanho Máximo da maior
              NIL , ;                           // [15] C Inicializador de Browse
              .T. , ;                           // [16] L Indica se o campo é virtual
              NIL )		

      oStruN9H:AddField( ;                      // Ord. Tipo Desc.
              "TMP_DTINVG" , ;                  // [01] C Nome do Campo
              "03" , ;                          // [02] C Ordem
              STR0027, ; //"Dt Vigência"        // [03] C Titulo do campo
              STR0027, ; //"Dt Vigência"        // [04] C Descrição do campo
              {}, ;                             // [05] A Array com Help
              TamSX3( "N9H_DTINVG" )[3]   , ;   // [06] C Tipo do campo
              PesqPict("N9H","N9H_DTINVG") , ;  // [07] C Picture
              NIL , ;                           // [08] B Bloco de Picture Var
              "" , ;                            // [09] C Consulta F3
              .T.    , ;                        // [10] L Indica se o campo é editável
              Nil , ;                           // [11] C Pasta do campo
              NIL , ;                           // [12] C Agrupamento do campo
              {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
              NIL   , ;                         // [14] N Tamanho Máximo da maior
              NIL , ;                           // [15] C Inicializador de Browse
              .T. , ;                           // [16] L Indica se o campo é virtual
              NIL )

      oStruN9H:AddField( ;                      // Ord. Tipo Desc.
              "TMP_DTFNVG" , ;                  // [01] C Nome do Campo
              "04" , ;                          // [02] C Ordem
              STR0050, ;       //"Dt.Fin.Vig."  // [03] C Titulo do campo
              STR0050, ;       //"Dt.Fin.Vig."  // [04] C Descrição do campo
              {}, ;                             // [05] A Array com Help
              TamSX3( "N9H_DTFNVG" )[3]   , ;   // [06] C Tipo do campo
              PesqPict("N9H","N9H_DTFNVG") , ;  // [07] C Picture
              NIL , ;                           // [08] B Bloco de Picture Var
              "" , ;                            // [09] C Consulta F3
              .T.    , ;                        // [10] L Indica se o campo é editável
              Nil , ;                           // [11] C Pasta do campo
              NIL , ;                           // [12] C Agrupamento do campo
              {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
              NIL   , ;                         // [14] N Tamanho Máximo da maior
              NIL , ;                           // [15] C Inicializador de Browse
              .T. , ;                           // [16] L Indica se o campo é virtual
              NIL )
      EndIf

      oStruN9H:AddField( ;                        // Ord. Tipo Desc.
                "TMP_VLINDT" , ;                  // [01] C Nome do Campo
                "04" , ;                          // [02] C Ordem
                STR0022, ; //Valor                // [03] C Titulo do campo
                STR0022, ; //Valor                // [04] C Descrição do campo
                {}, ;                             // [05] A Array com Help
                TamSX3( "N9H_VLINDT" )[3]   , ;   // [06] C Tipo do campo
                PesqPict("N9H","N9H_VLINDT") , ;  // [07] C Picture
                NIL , ;                           // [08] B Bloco de Picture Var
                "" , ;                            // [09] C Consulta F3
                .T.    , ;                        // [10] L Indica se o campo é editável
                Nil , ;                           // [11] C Pasta do campo
                NIL , ;                           // [12] C Agrupamento do campo
                {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
                NIL   , ;                         // [14] N Tamanho Máximo da maior
                NIL , ;                           // [15] C Inicializador de Browse
                .T. , ;                           // [16] L Indica se o campo é virtual
                NIL )

     oStruN9H:AddField( ;                        // Ord. Tipo Desc.
                "TMP_OBSERV" , ;                  // [01] C Nome do Campo
                "05" , ;                          // [02] C Ordem
                STR0044, ; //Valor                // [03] C Titulo do campo
                STR0044, ; //Valor                // [04] C Descrição do campo
                {}, ;                             // [05] A Array com Help
                TamSX3( "N9H_OBSERV" )[3]   , ;   // [06] C Tipo do campo
                PesqPict("N9H","N9H_OBSERV") , ;  // [07] C Picture
                NIL , ;                           // [08] B Bloco de Picture Var
                "" , ;                            // [09] C Consulta F3
                .T.    , ;                        // [10] L Indica se o campo é editável
                Nil , ;                           // [11] C Pasta do campo
                NIL , ;                           // [12] C Agrupamento do campo
                {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
                NIL   , ;                         // [14] N Tamanho Máximo da maior
                NIL , ;                           // [15] C Inicializador de Browse
                .T. , ;                           // [16] L Indica se o campo é virtual
                NIL )
                
     oStruN9H:AddField( ;                        // Ord. Tipo Desc.
                "TMP_UNIMED" , ;                  // [01] C Nome do Campo
                "05" , ;                          // [02] C Ordem
                STR0045, ; //Unid Medida          // [03] C Titulo do campo
                STR0045, ; //Unid Medida          // [04] C Descrição do campo
                {}, ;                             // [05] A Array com Help
                TamSX3( "N9H_UNIMED" )[3]   , ;   // [06] C Tipo do campo
                PesqPict("N9H","N9H_UNIMED") , ;  // [07] C Picture
                NIL , ;                           // [08] B Bloco de Picture Var
                "SAH" , ;                         // [09] C Consulta F3
                .T.    , ;                        // [10] L Indica se o campo é editável
                Nil , ;                           // [11] C Pasta do campo
                NIL , ;                           // [12] C Agrupamento do campo
                {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
                NIL   , ;                         // [14] N Tamanho Máximo da maior
                NIL , ;                           // [15] C Inicializador de Browse
                .T. , ;                           // [16] L Indica se o campo é virtual
                NIL )
                        
    oStruN9H:AddField( ;                        // Ord. Tipo Desc.
              "TMP_SUBST" , ;                   // [01] C Nome do Campo
              "06" , ;                          // [02] C Ordem
              STR0028, ; //Substituir           // [03] C Titulo do campo
              STR0030, ; //Substituir valores.  // [04] C Descrição do campo
              {}, ;                             // [05] A Array com Help
              "L"   , ;                         // [06] C Tipo do campo
              "@!" , ;                          // [07] C Picture
              NIL , ;                           // [08] B Bloco de Picture Var
              "" , ;                            // [09] C Consulta F3
              .T.    , ;                        // [10] L Indica se o campo é editável
              Nil , ;                           // [11] C Pasta do campo
              NIL , ;                           // [12] C Agrupamento do campo
              {}      , ;                       // [13]   A Lista de valores permitido  do campo combo
              NIL   , ;                         // [14] N Tamanho Máximo da maior
              NIL , ;                           // [15] C Inicializador de Browse
              .T. , ;                           // [16] L Indica se o campo é virtual
              NIL )

    oStruN9H:SetProperty( '*'  , MVC_VIEW_GROUP_NUMBER , 'GRP_SUBST' )
  EndIf


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA580VLUF
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function OGAA580VLUF(cAliaA,cPar01,cPar02)

  If Empty(cPar02)
    Help(" ",1,"ATEINVALID")
    Return .f.
  Elseif cPar02 < cPar01
    Help(" ",1,"DEATEINVAL")
    Return .f.
  Endif

  If cPar02 = replicate('Z',Len(cPar02))
    Return .t.
  ElseIf !ExistCpo(cAliaA,"12"+cPar02)
    Return .f.
  Endif

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA580VLIND
Função de validação do indice
@author  jefferson
@since   24/04/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGAA580VLIND()

  Local oView       := FwViewActive()
  Local oModel      := oView:GetModel()
  Local oModelN9H   := oModel:GetModel("OGAA580_N9H")

  Local ctIPO       := posicione("NK0",1,xFilial("NK0")+oModelN9H:GetValue("N9H_INDICE"),"NK0_TPCOTA")

  If ctIPO = " "
    Help( ,,STR0010,, STR0016, 1, 0,,,,,,{STR0018} ) //Ajuda - "Índice não encontrado. - "Favor informar um índice válido"
    Return .f.
  elseif ctIPO != "T"
    Help( ,,STR0010,, STR0017, 1, 0,,,,,,{STR0019} ) //Ajuda - "Índice não é do tipo T - Tabela. - "Campo TP.índice - OGA080"
    Return .f.
  EndIf

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDupl
Validação de registro duplicado.
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function VldDupl(cIndice, cProduto, cSafra, cTipo, dDataVig, cUfOrig, cUfDest, cRegiao, dDtFnVg)
	Local cAlias  := GetNextAlias()
	Local cMsg    := ""

	BeginSQL Alias cAlias
		SELECT N9H_INDICE
		  FROM %table:N9H%
		 WHERE N9H_FILIAL  = %xFilial:N9H%
		   AND N9H_INDICE  = %Exp: cIndice%
		   AND N9H_CODSAF  = %Exp: cSafra%
		   AND N9H_PROD    = %Exp: cProduto%		   
		   AND N9H_UFORIG  = %Exp: cUfOrig%		   
		   AND N9H_UFDEST  = %Exp: cUfDest%		   
		   AND N9H_TIPO    = %Exp: cTipo%
		   AND N9H_DTINVG  = %Exp: dtos(dDataVig)%
		   AND N9H_DTFNVG  = %Exp: dtos(dDtFnVg)%
		   AND N9H_CODREG  = %Exp: cRegiao%	
		   AND %notDel%
		GROUP BY N9H_INDICE
	EndSQL

	If !Empty((cAlias)->N9H_INDICE)
		cMsg := STR0043   + ": " + CRLF + CRLF                //Registro já cadastrado.
		cMsg +=  STR0025  + ": " + alltrim(cIndice) + CRLF    //"Índice:  "
		cMsg +=  STR0026  + ": " + alltrim(cSafra) + CRLF     //"Safra:   "
		cMsg +=  STR0036  + ": " + alltrim(cProduto) + CRLF   //"Produto: " 		
		cMsg +=  STR0037  + ": " + alltrim(cTipo) + CRLF		  //"Tipo: "
		cMsg +=  STR0038  + ": " + cUfOrig + CRLF	            //"UF Origem: "
		cMsg +=  STR0039  + ": " + cUfDest + CRLF	            //"UF Destino: "
		cMsg +=  STR0046  + ": " + cRegiao + CRLF		          //"Região: " 
		cMsg +=  STR0040  + ": " + dtos(dDataVig)		          //"Data Vigência: " 
		cMsg +=  STR0050  + ": " + dtos(dDtFnVg)		          //"Dt.Fin.Vig.: " 
		Help( ,, STR0010,, cMsg, 1, 0,,,,,,{STR0041} )	//"Ajuda" //"Por favor, verifique dados informados."
		Return .F.
	EndIf

	(cAlias)->(dbCloseArea())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSafra
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function VldSafra()
  Local aArea       := GetArea()
  IF !Empty(fwFldGet("TMP_CODSAF"))
    NJU->(DbSetOrder(1))
    If !NJU->(dbseek(xFilial("NJU")+fwFldGet("TMP_CODSAF")))
      RestArea(aArea)
      REturn .f.
    EndIf
  EndIf
   RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldIndice
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function VldIndice()
  Local aArea       := GetArea()
  Local ctIPO       := ""

  IF !Empty(fwFldGet("TMP_INDICE"))
    cTipo := posicione("NK0",1,xFilial("NK0")+fwFldGet("TMP_INDICE"),"NK0_TPCOTA")
    If ctIPO != "T"
      RestArea(aArea)
      Return .f.
    EndIf
  Endif
  RestArea(aArea)
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidUMed
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ValidUMed()

Local aArea       := GetArea()
  IF !Empty(fwFldGet("TMP_UNIMED"))
    SAH->(DbSetOrder(1))
    If !SAH->(dbseek(xFilial("SAH")+fwFldGet("TMP_UNIMED")))
      RestArea(aArea)
      REturn .f.
    EndIf
  EndIf
   RestArea(aArea)
Return .t.

/*/{Protheus.doc} fValPer2(oModel)
Verifica se o usuário tem permição para alterar o indice quando em inclusão/alteração/exclusão
@type  Static Function
@author rafael.kleestadt
@since 15/11/2018
@version 1.0
@param oModel, object, objeto do modelo principal
@return True, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fValPer2(oModel)
  Local oModelN9H  := oModel:GetModel("OGAA580_N9H")
  Local cCodUsu    := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9H:GetValue("N9H_INDICE"),"NK0_CODUSU")
  Local cCodGru    := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9H:GetValue("N9H_INDICE"),"NK0_GRPUSU")
  Local cDesInd    := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9H:GetValue("N9H_INDICE"),"NK0_DESCRI")
	Local cCodBls    := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9H:GetValue("N9H_INDICE"),"NK0_CODBOL")
  Local aGrpUsuLog := UsrRetGrp(cUserName,RetCodUsr()) //Retorna um array contendo todos os códigos dos Grupos de Usuário em que o Usuário, passado na função, pertence.
  Local nPos       := 0
  Local lRet       := .T.
  Local lUsuario   := .F.
	Local lGrupo     := .F.

	Do Case
		Case !Empty(cCodUsu) //Se restrição por usuário.
			lUsuario := .T.
		Case !Empty(cCodGru) //Se restrição por grupo de usuários.
			lGrupo := .T.
		Case !Empty(cCodBls) //se não tiver restrição por usuário ou grupo verigica se na bolsa vinculada tem alguma restrição.
			cCodUsu := POSICIONE("N8C", 1, FwxFilial("N8C")+cCodBls, "N8C_CODUSU")
			cCodGru := POSICIONE("N8C", 1, FwxFilial("N8C")+cCodBls, "N8C_GRPUSU")
			If !Empty(cCodUsu) //Se restrição por usuário.
				lUsuario := .T.
			ElseIf !Empty(cCodGru) //Se restrição por grupo de usuários.
				lGrupo := .T.
			EndIf
	End Case

	If lUsuario
		If cCodUsu <> RetCodUsr() //Retorna o código do usuário corrente.
			lRet := .F.
		EndIf
	ElseIf lGrupo
		nPos := aScan(aGrpUsuLog, cCodGru)
		//Se não encontrou o grupo nos grupos em que o usuário logado está contido então retorna falso.
		If nPos == 0
			lRet := .F.
		EndIf
	EndIf

  //Se lRet ficou falso
  If !lRet

    HELP(' ',1,STR0025,,STR0047+ALLTRIM(cUserName)+ STR0048 +ALLTRIM(cDesInd)+".",2,0,,,,,, {STR0049})
            //"Índice"###"O usuário "###" não tem permissão para alterar o(s) índice(s) "###"Configure a permissão de usuário/grupo de usuários por meio do programa de cadastro de índices de mercado OGA080."
    Return .F.

  EndIf

Return .T.

/*/{Protheus.doc} fValPer1(oModel)
Verifica se o usuário tem permição para alterar o indice quando em cópia/alteração em lote
@type  Static Function
@author rafael.kleestadt
@since 15/11/2018
@version 1.0
@param oModel, object, objeto do modelo principal
@return True, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fValPer1(oModel)
  Local oModelN9HGr := oModel:GetModel("MODEL_GRID")
  Local cDesInd     := ""
  Local cCodUsu     := "" 
  Local cCodGru     := "" 
  Local cCodBls     := "" 
  Local xDesIncs    := NIL
  Local aGrpUsuLog  := UsrRetGrp(cUserName,RetCodUsr()) //Retorna um array contendo todos os códigos dos Grupos de Usuário em que o Usuário, passado na função, pertence.
  Local nPos        := 0
  Local nX          := 0
  Local lUsuario    := .F.
	Local lGrupo      := .F.

  For nX := 1 To oModelN9HGr:Length()
    oModelN9HGr:Goline(nX)
    If ! oModelN9HGr:IsDeleted()

      cDesInd  := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9HGr:GetValue("N9H_INDICE"),"NK0_DESCRI")
      cCodUsu  := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9HGr:GetValue("N9H_INDICE"),"NK0_CODUSU")
      cCodGru  := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9HGr:GetValue("N9H_INDICE"),"NK0_GRPUSU")
      cCodBls  := POSICIONE("NK0",1,XFILIAL("NK0")+oModelN9HGr:GetValue("N9H_INDICE"),"NK0_CODBOL")
      lUsuario := .F.
      lGrupo   := .F.

      //Se foi informado o usuário para o índice então valida por este pois é mais restrito.
      If !Empty(cCodUsu) //Se restrição por grupo de usuários.
        lUsuario := .T.
      ElseIf !Empty(cCodGru) //Se restrição por grupo de usuários.
        lGrupo := .T.
      ElseIf !Empty(cCodBls) //se não tiver restrição por usuário ou grupo verigica se na bolsa vinculada tem alguma restrição.
			  
        cCodUsu := POSICIONE("N8C", 1, FwxFilial("N8C")+cCodBls, "N8C_CODUSU")
			  cCodGru := POSICIONE("N8C", 1, FwxFilial("N8C")+cCodBls, "N8C_GRPUSU")

			  If !Empty(cCodUsu) //Se restrição por usuário.
				  lUsuario := .T.
			  ElseIf !Empty(cCodGru) //Se restrição por grupo de usuários.
				  lGrupo := .T.
			  EndIf

      EndIf

      If lUsuario
        If cCodUsu <> RetCodUsr() //Retorna o código do usuário corrente.
          //Somente converte a variavel de controle se ouver alguma divergência
          If ValType(xDesIncs) <> "A"
            xDesIncs := {}
          EndIf

          If aScan(xDesIncs, ALLTRIM(cDesInd)) == 0
            AADD(xDesIncs, ALLTRIM(cDesInd))
          EndIf
        EndIf
      ElseIf lGrupo
        nPos := aScan(aGrpUsuLog, cCodGru)

        //Se não encontrou o grupo nos grupos em que o usuário logado está contido então não permite a Inclusão/alteração
        If nPos == 0
          //Somente converte a variavel de controle se ouver alguma divergência
          If ValType(xDesIncs) <> "A"
            xDesIncs := {}
          EndIf

          If aScan(xDesIncs, ALLTRIM(cDesInd)) == 0
            AADD(xDesIncs, ALLTRIM(cDesInd))
          EndIf
        EndIf
      EndIf

    EndIf
  Next nX

  //Se xDesIncs não esta vazio
  If xDesIncs <> NIL

    HELP(' ',1,STR0025,,STR0047+ALLTRIM(cUserName)+ STR0048 +ALLTRIM(ArrTokStr(xDesIncs, ", "))+".",2,0,,,,,, {STR0049})
            //"Índice"###"O usuário "###" não tem permissão para alterar o(s) índice(s) "###"Configure a permissão de usuário/grupo de usuários por meio do programa de cadastro de índices de mercado OGA080."
    Return .F.

  EndIf

Return .T.

/*/{Protheus.doc} fAjusDtFin(oModel)
Na cópia em lote, se encontrar registros com a mesma filial, índice, produto e safra, altera a data de final de vigência para a data atal.
@type  Static Function
@author rafael.kleestadt
@since 16/11/2018
@version 1.0
@param oModel, object, objeto do modelo principal
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fAjusDtFin(oModel)
  Local oModelN9HGr := oModel:GetModel("MODEL_GRID")
  Local nX          := 0
  
  dtVigen := daysub(dtVigen, 1) //subtrai um dia da data

  For nX := 1 To oModelN9HGr:Length()
    oModelN9HGr:Goline(nX)
    If ! oModelN9HGr:IsDeleted()

      DbSelectArea("N9H")
      N9H->(DbSetOrder(1)) //N9H_FILIAL+N9H_INDICE+N9H_PROD+N9H_CODSAF+N9H_ITETAB
      If N9H->(DbSeek(oModelN9HGr:GetValue("N9H_FILIAL")+oModelN9HGr:GetValue("N9H_INDICE")+oModelN9HGr:GetValue("N9H_PROD")+oModelN9HGr:GetValue("N9H_CODSAF")))
        While N9H->(!EOF()) .And. N9H->(N9H_FILIAL+N9H_INDICE+N9H_PROD+N9H_CODSAF) == oModelN9HGr:GetValue("N9H_FILIAL")+oModelN9HGr:GetValue("N9H_INDICE")+oModelN9HGr:GetValue("N9H_PROD")+oModelN9HGr:GetValue("N9H_CODSAF")
          
          If RecLock("N9H", .F.)

            N9H->N9H_DTFNVG := dtVigen
          
            N9H->(MsUnlock())
          EndIf

          N9H->(DbSkip())
        EndDo
      EndIf
      N9H->(dbCloseArea())

    EndIf
  Next nX

Return .T.

/*/{Protheus.doc} fAtuPrRec(aInd)
Busca os DCOs onde o índice alterado esta sendo utilizado e chama a função de atualização da previsão de recebimento.
@type  Static Function
@author rafael.kleestadt
@since 26/11/2018
@version 1.0
@param aInd, array, array contendo os indices alterados para ser usado na busca.
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fAtuPrRec(aInd)
  Local nX        := 0
  Local cAliasQry := GetNextAlias()
  Local aDcos     := {}

  For nX := 1 To Len(aInd)

	cQry := " SELECT N9H.*, N9U.R_E_C_N_O_ AS RECNO "
	cQry += " FROM " + RetSqlName('N9U') + " N9U "
	cQry += " INNER JOIN " + RetSqlName('N9N') + " N9N "
	cQry += " ON N9N.N9N_FILIAL = N9U.N9U_FILIAL "
	cQry += " AND N9N.N9N_NUMERO = N9U.N9U_NUMAVI "
	cQry += " INNER JOIN " + RetSqlName('N9H') + " N9H "
	cQry += " ON ( N9H.N9H_INDICE = N9N.N9N_INDICE "
	cQry += " OR N9H.N9H_INDICE = N9N.N9N_INDPRE ) "
	cQry += " AND N9H.N9H_FILIAL = N9N.N9N_FILIAL "
	cQry += " WHERE N9U.D_E_L_E_T_ = ' ' "
	cQry += " AND N9N.D_E_L_E_T_ = ' ' "
	cQry += " AND N9H.D_E_L_E_T_ = ' ' "
	cQry += " AND N9U.N9U_STATUS < '3' "
	cQry += " AND N9N.N9N_FILIAL = '" + aInd[nX,1] + "' "
	cQry += " AND N9N.N9N_SAFRA = '" + aInd[nX,2] + "' "
	cQry += " AND N9N.N9N_CODPRO = '" + aInd[nX,3] + "' "
	cQry += " AND N9H.N9H_ITETAB = '" + aInd[nX,4] + "' "	

    cQry := ChangeQuery(cQry)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry), cAliasQry, .F., .T.)
		If (cAliasQry)->(!EoF())
			While (cAliasQry)->(!EoF())

        DbSelectArea("N9U")
        N9U->(DbGoTo((cAliasQry)->RECNO))
        cTpReg  := Posicione("N9N", 1, N9U->N9U_FILIAL+N9U->N9U_NUMAVI, "N9N_TIPREG")
        cCodReg := fGetCdReg(N9U->N9U_FILORI, cTpReg)
        cUFSM0  := POSICIONE("SM0", 1,cEmpAnt+N9U->N9U_FILORI,"M0_ESTENT")
        dDtLei  := DTOS(Posicione("N9N", 1, N9U->N9U_FILIAL+N9U->N9U_NUMAVI, "N9N_DTLEIL"))

        If (cCodReg = (cAliasQry)->N9H_CODREG .OR. Empty((cAliasQry)->N9H_CODREG)) .AND. ; //Mesma região do índice ou região vazia
           (cUFSM0  = (cAliasQry)->N9H_UFORIG .OR. Empty((cAliasQry)->N9H_UFORIG)) .AND. ; //Mesma UF de Origem ou UF de origem não informado
           (cAliasQry)->N9H_DTINVG <= dDtLei .AND. (cAliasQry)->N9H_DTFNVG >= dDtLei       //Data do leilão do aviso entre a data de vigência índice

          //Atualiza a previsão de recebimento DCO
          If aScan(aDcos, N9U->N9U_NUMAVI+N9U->N9U_NUMDCO) == 0
            OGA810AVLP(N9U->N9U_FILIAL, N9U->N9U_NUMAVI, N9U->N9U_NUMDCO)
            aAdd(aDcos, N9U->N9U_NUMAVI+N9U->N9U_NUMDCO)
          EndIf
        
        EndIf

        N9U->(DbCloseArea())

				(cAliasQry)->(dbSkip())
			EndDo
    EndIf
    (cAliasQry)->(DbCloseArea())

  Next nX

Return .T.

/*/{Protheus.doc} fGetCdReg
Função que retorna o código da região com base na filial de origem do DCO do Aviso Pepro e tipo da região
@type  Static Function
@author rafael.kleestadt
@since 23/11/2018
@version 1.0
@param cFilOriN9U, caractere, filial de origem do dco do aviso pepro
@param cTpReg, caractere, tipo de região do aviso pepro
@return cCodReg, caractere, código da região com base na filial de origem do DCO do Aviso Pepro e tipo da região
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetCdReg(cFilOriN9U, cTpReg)

	Local cUFSM0    := POSICIONE("SM0",1,cEmpAnt+cFilOriN9U,"M0_ESTENT")    
	Local cCISM0    := SubStr(POSICIONE("SM0",1,cEmpAnt+cFilOriN9U,"M0_CODMUN"), 3, TamSx3('CC2_CODMUN')[1])
	Local cCodReg   := ""
	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()

	//buscar região com estado e cidade da filial do aviso
	cQuery := "     SELECT NBR.NBR_CODREG FROM " + RetSqlName("NBR") + " NBR "
	cQuery += " INNER JOIN " + RetSqlName("NBQ") + " NBQ  "
	cQuery += "         ON NBQ_CODREG = NBR_CODREG and NBQ.D_E_L_E_T_ = ' '"
	cQuery += "      WHERE NBQ_TIPREG = '"+ cTpReg + "'"
	cQuery += "        AND NBR_ESTADO = '"+ cUFSM0 + "'"
	cQuery += "        AND NBR_CODMUN = '"+ cCISM0 + "'"
	cQuery += "        AND NBR.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )
		cCodReg   := (cAliasQry)->NBR_CODREG	
	EndIf
	(cAliasQry)->(DbcloseArea())

Return cCodReg

/*/{Protheus.doc} GrvModel(oModel)
Função de gravação do modelo quando não chamado pelas funções OGAA580AAUX e OGAA580CPY
@type  Static Function
@author rafael.kleestadt
@since 28/11/2018
@version version
@param oModel, Object, objeto do modelo principal
@return lCommit, logycal, retorno da função de commit dos ados da tela
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvModel(oModel)
  Local oModelN9H   := oModel:GetModel("OGAA580_N9H")
  Local oModelN9HGr := oModel:GetModel("MODEL_GRID")
  Local nX          := 0
  Local aArea       := GetArea()
  Local aInd        := {}
  Local lCommit     := FwFormCommit(oModel)

  If !FWIsInCallStack("OGAA580AAUX")  .AND. !FWIsInCallStack("OGAA580CPY") .AND. oModelN9HGr:IsModified() .AND. lCommit 
    For nX := 1 To oModelN9HGr:Length()
      oModelN9HGr:Goline(nX)
      If !oModelN9HGr:IsDeleted()
        cChave := oModelN9H:GetValue("N9H_FILIAL")+oModelN9H:GetValue("N9H_CODSAF")+;
                  oModelN9H:GetValue("N9H_PROD")+oModelN9HGr:GetValue("N9H_ITETAB")

        nPos   := aScan( aInd, { |x| AllTrim( x[5] ) == AllTrim(cChave) } )

        If nPos == 0
          aAdd(aInd, {oModelN9H:GetValue("N9H_FILIAL"),oModelN9H:GetValue("N9H_CODSAF"),oModelN9H:GetValue("N9H_PROD"),oModelN9HGr:GetValue("N9H_ITETAB"), cChave})
        EndIf
      EndIf
    Next nX
  EndIf

  if !Empty(aInd) .AND. lCommit
      fAtuPrRec(aInd)
  EndIf

  RestArea(aArea)

Return lCommit
