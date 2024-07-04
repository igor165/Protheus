#include "VDFC010.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VDFC010  ³ Autor ³ TOTVS.       				 ³ Data ³ 01/07/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processo de Estágio Probatório e Vitaliciamento.        		     ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos Pereira³11/03/14³xxx. xxxxxxx     ³ Ajuste na concatenacao em query para       ³±±
±±³              ³        ³REQ. xxxxxx      ³ diferenciar conforme banco utilizado 		 ³±±
±±³              ³        ³                 ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFC010
Processo de Estágio Probatório e Vitaliciamento
@author Everson S P Junior
@since 01/07/2013
@version P11
@Obs Processo de Estágio Probatório e Vitaliciamento visa centralizar 
e fornecer informações aos responsáveis pela tomada de decisão quanto 
à efetivação e vitaliciamento de servidores e membros, respectivamente
/*/
//-------------------------------------------------------------------
Function VDFC010()//VDFC010
Local oBrowse
Local aButtons

Private aFielCamp := {} 

If  VDFC010VL() .Or. IsBlind()
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'SRA' )
	oBrowse:SetUseCursor(.F.)
	oBrowse:SetbOKMVCWindow ({|oModel|SetVld(oModel,oBrowse)})
	oBrowse:SetDescription( STR0001)//'Membros'
	oBrowse:setfilterdefault("RA_CATFUNC =='0' .AND. EMPTY(RA_DEFETIV) .AND. EMPTY(RA_DEMISSA) ")
	oBrowse:Activate()
Else	
	MsgAlert(STR0002)//"Usuário não possui acesso!"
EndIf

Return NIL
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.VDFC010' OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina Title 'Relatório '  Action 'VDFR010()'       OPERATION 3 ACCESS 0
Return aRotina
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruSRA := FWFormStruct( 1, 'SRA', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruSR8 := FWFormStruct( 1, 'SR8', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel   
Local nVDFVIT1  := SuperGetMv('MV_VDFVIT1')
Local nTotPror := 0
Local nPesoCal := 0
Local nDias    := 0
Local nMes     := 0
Local cDesprob := ''
Local dDatas

oStruSRA:AddField(                       ;// Ord. Tipo Desc.
AllTrim( STR0004 )                   , ;// [01]  C   Titulo do campo//'Data Prev'
AllTrim( STR0005)   , ; // [02]  C   ToolTip do campo//'Data Prev.p/vitaliciamento'
'RA_DATVITA'                             , ;// [03]  C   Id do Field
'D'                                      , ;// [04]  C   Tipo do campo
8                                        , ;// [05]  N   Tamanho do campo
0                                        , ;// [06]  N   Decimal do campo
NIL                                      , ;// [07]  B   Code-block de validação do campo
NIL										 , ;// [08]  B   Code-block de validação When do campo
NIL                                      , ;// [09]  A   Lista de valores permitido do campo
NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
NIL                                      , ;// [11]  B   Code-block de inicializacao do campo
NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
.F.                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
.T.                                        )// [14]  L   Indica se o campo é virtual


oStruSRA:AddField(                         ;// Ord. Tipo Desc.
AllTrim( STR0006 )                   , ;// [01]  C   Titulo do campo//'Temp Prev'
AllTrim( STR0007)  , ;// [02]  C   ToolTip do campo//'Tempo Prev.p/vitaliciamento'
'RA_TEMVITA'                             , ;// [03]  C   Id do Field
'C'                                      , ;// [04]  C   Tipo do campo
40                                       , ;// [05]  N   Tamanho do campo
0                                        , ;// [06]  N   Decimal do campo
FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
NIL                                      , ;// [08]  B   Code-block de validação When do campo
NIL                                      , ;// [09]  A   Lista de valores permitido do campo
NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
NIL                                      , ;// [11]  B   Code-block de inicializacao do campo
NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
.T.                                        )// [14]  L   Indica se o campo é virtual


oStruSR8:AddField(                         ;// Ord. Tipo Desc.                     
AllTrim( STR0008 )            , ;// [01]  C   Titulo do campo//'Des prazo probat'
AllTrim( STR0009)    , ;// [02]  C   ToolTip do campo//'Desconta prazo probatório'
'R8_DESPROB'                             , ;// [03]  C   Id do Field
'C'                                      , ;// [04]  C   Tipo do campo
1                                        , ;// [05]  N   Tamanho do campo
0                                        , ;// [06]  N   Decimal do campo
FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
NIL                                      , ;// [08]  B   Code-block de validação When do campo
{STR0010,STR0011}, ;////'1=Lista e Prorroga'//'2=Lista e Não Prorroga'
NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
{||nPesoCal:=Posicione("RCM",1,FwxFilial("RCM")+SR8->R8_TIPOAFA,"RCM_DIAVIT"),;
cDesprob:=Posicione("RCM",1,FwxFilial("RCM")+SR8->R8_TIPOAFA,"RCM_PROVIT"),cDesprob}, ; // [11]  B   Code-block de inicializacao do campo
NIL                                      , ;//[12]  L   Indica se trata-se de um campo chave
NIL                                      , ;//[13]  L   Indica se o campo pode receber valor em uma operação de update.
.F.                                        )//[14]  L   Indica se o campo é virtual


oStruSR8:AddField(                         ;//Ord. Tipo Desc.
AllTrim( STR0012 )                , ;//[01]  C   Titulo do campo//'Prorro Prazo'
AllTrim( STR0013)         , ;//[02]  C   ToolTip do campo//'Prorrogacao de prazo'
'R8_PROPRAZO'                            , ;//[03]  C   Id do Field
'N'                                      , ;//[04]  C   Tipo do campo
3                                        , ;//[05]  N   Tamanho do campo
1                                        , ;//[06]  N   Decimal do campo
FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;//[07]  B   Code-block de validação do campo
FwBuildFeature( STRUCT_FEATURE_WHEN,"VAZIO()"), ;//[08]  B   Code-block de validação When do campo
NIL                                      , ;//[09]  A   Lista de valores permitido do campo
NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
{||IIf(cDesprob == '1',(SR8->R8_DURACAO*nPesoCal),0)}, ;//[11]  B   Code-block de inicializacao do campo
NIL                                      , ;//[12]  L   Indica se trata-se de um campo chave
NIL                                      , ;//[13]  L   Indica se o campo pode receber valor em uma operação de update.
.F.                                        )//[14]  L   Indica se o campo é virtual

oStruSR8:AddField(                         ;// Ord. Tipo Desc.
AllTrim( STR0014 )                  , ;// [01]  C   Titulo do campo//'Nro. Do Docu'
AllTrim( STR0015)            , ;// [02]  C   ToolTip do campo//'Nro. Do Documento'
'R8_NUMDOC'                             , ;// [03]  C   Id do Field
'C'                                      , ;// [04]  C   Tipo do campo
04                                       , ;// [05]  N   Tamanho do campo
0                                        , ;// [06]  N   Decimal do campo
FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
NIL                                      , ;// [08]  B   Code-block de validação When do campo
NIL                                      , ;// [09]  A   Lista de valores permitido do campo
NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
{||}                                     , ;// [11]  B   Code-block de inicializacao do campo
NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
.T.                                        )// [14]  L   Indica se o campo é virtual

oStruSR8:AddField(                         ;// Ord. Tipo Desc.
AllTrim( STR0016 )                   , ;// [01]  C   Titulo do campo//'Ano do Docum'
AllTrim( STR0017)  , ;// [02]  C   ToolTip do campo//'Ano do Documento'
'R8_ANO'                             , ;// [03]  C   Id do Field
'C'                                      , ;// [04]  C   Tipo do campo
04                                       , ;// [05]  N   Tamanho do campo
0                                        , ;// [06]  N   Decimal do campo
FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
NIL                                      , ;// [08]  B   Code-block de validação When do campo
NIL                                      , ;// [09]  A   Lista de valores permitido do campo
NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
{||}                  , ;// [11]  B   Code-block de inicializacao do campo
NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
.T.                                        )// [14]  L   Indica se o campo é virtual


cCposLib := "RA_FILIAL,RA_CC+RA_MAT,RA_NOME,RA_DTNOMEA"
SX3->(DbSetOrder(1))
SX3->(MsSeek("SRA"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
	If (!Alltrim(SX3->X3_CAMPO) $ cCposLib)
	   oStruSRA:RemoveField(Alltrim(SX3->X3_CAMPO))
	EndIf
	SX3->(dbSkip())
EndDo

cCposLib := "R8_FILIAL,R8_MAT,R8_DATAINI,R8_TIPO,R8_TIPOAFA,R8_DATAINI,R8_DATAFIM,R8_DESCTP,R8_DURACAO"
SX3->(DbSetOrder(1))
SX3->(MsSeek("SR8"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SR8"
	If (!Alltrim(SX3->X3_CAMPO) $ cCposLib)
	   oStruSR8:RemoveField(Alltrim(SX3->X3_CAMPO))
	EndIf
	SX3->(dbSkip())
EndDo


oModel := MPFormModel():New( 'VDFC010',/*PRE*/, {||.T.},{|oModel|.T.},{||.T.})

//AddFields(cId, cOwner, oModelStruct, bPre, bPost , bLoad )
oModel:AddFields( 'SRAMASTER', /*cOwner*/, oStruSRA,/*bPre*/,/*bPost*/,{|oMdl|CALCPRO( oMdl ) })

oModel:AddGrid( 'SR8DETAIL', 'SRAMASTER', oStruSR8,{|oModel|.T.}, {|oModel|.T.}, {|oModel|.T.}, {|oModel|.T.}, {|oMdl| SelecSR8( oMdl ) })

oModel:AddCalc( 'VDFC010CALC1', 'SRAMASTER', 'SR8DETAIL', 'R8_DURACAO', 'R8__TOTDURA', 'SUM',{|oFW|CALCAU( oFW, .T.,cDesprob) },,STR0018 )//'Totais de Dias de Ausências'
oModel:AddCalc( 'VDFC010CALC1', 'SRAMASTER', 'SR8DETAIL', 'R8_PROPRAZO','R8__TOTPROR', 'SUM',/*{|oFW| CALCPRO( oFW, .T.,SRA->RA_DTNOMEA) }*/,,'Totais de Dias de Prorrogados' )

oModel:SetRelation( 'SR8DETAIL', { { 'R8_FILIAL', 'FwxFilial( "SRA" )' }, { 'R8_MAT', 'RA_MAT' }}, SR8->(IndexKey( 1 ))) //Posicione("RCM",1,FwxFilial("RCM")+SR8->R8_TIPOAFA,"RCM_PROVIT")<> '3'

//Permissão de grid sem dados
oModel:GetModel( 'SR8DETAIL' ):SetOptional( .T. )

oModel:SetDescription( STR0019 )//'Vitaliciamento - Promotores Substitutos'

oModel:GetModel( 'SRAMASTER' ):SetDescription( STR0020 )//'Vitaliciamento - Promotores Substitutos'

oModel:GetModel( 'SR8DETAIL' ):SetDescription( STR0021)//'Afastamentos para o Vitaliciamento'

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruSRA := FWFormStruct( 2, 'SRA' )
Local oStruSR8 := FWFormStruct( 2, 'SR8' )
Local cCposLib := ''
Local oModel   := FWLoadModel( 'VDFC010' )
Local oView
Local oCalc1  

cCposLib := "RA_NOME,RA_DTNOMEA"
SX3->(DbSetOrder(1))
SX3->(MsSeek("SRA"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
	If (!Alltrim(SX3->X3_CAMPO) $ cCposLib)
	   oStruSRA:RemoveField(Alltrim(SX3->X3_CAMPO))
	EndIf
	SX3->(dbSkip())
EndDo

oStruSR8:RemoveField('R8_DATA')

oStruSRA:SetProperty('RA_DTNOMEA', MVC_VIEW_ORDEM,'34')

cCposLib := "R8_DATAINI,R8_DATAFIM,R8_DESCTP,R8_DURACAO"
SX3->(DbSetOrder(1))
SX3->(MsSeek("SR8"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SR8"
	If (!Alltrim(SX3->X3_CAMPO) $ cCposLib)
	   oStruSR8:RemoveField(Alltrim(SX3->X3_CAMPO))
	EndIf
	SX3->(dbSkip())
EndDo


oStruSRA:AddField( ;                        // Ord. Tipo Desc.
'RA_DATVITA'                       , ;      // [01]  C   Nome do Campo
'40'                               , ;      // [02]  C   Ordem
AllTrim( STR0022) , ;  // [03]  C   Titulo do campo//'Data Prev.p/vitaliciamento'
AllTrim( STR0023 ), ;  // [04]  C   Descricao do campo//'Data Prev.p/vitaliciamento'
{ STR0024 } , ;        // [05]  A   Array com Help//'Data Prev.p/vitaliciamento'
'D'                                , ;      // [06]  C   Tipo do campo
'@D'                               , ;      // [07]  C   Picture
NIL                                , ;      // [08]  B   Bloco de Picture Var
''                                 , ;      // [09]  C   Consulta F3
.T.                                , ;      // [10]  L   Indica se o campo é alteravel
NIL                                , ;      // [11]  C   Pasta do campo
NIL                                , ;      // [12]  C   Agrupamento do campo
NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
NIL                                , ;      // [15]  C   Inicializador de Browse
.F.                                , ;      // [16]  L   Indica se o campo é virtual
NIL                                , ;      // [17]  C   Picture Variavel
NIL                                )        // [18]  L   Indica pulo de linha após o campo


oStruSRA:AddField( ;                        // Ord. Tipo Desc.
'RA_TEMVITA'                       , ;      // [01]  C   Nome do Campo
'41'                               , ;      // [02]  C   Ordem
AllTrim( STR0025) , ; // [03]  C   Titulo do campo//'Tempo Prev.p/vitaliciamento'
AllTrim( STR0026 ), ; // [04]  C   Descricao do campo//'Tempo Prev.p/vitaliciamento'
{ STR0027 } , ;       // [05]  A   Array com Help//'Tempo Prev.p/vitaliciamento'
'C'                                , ;      // [06]  C   Tipo do campo
'@!'                               , ;      // [07]  C   Picture
NIL                                , ;      // [08]  B   Bloco de Picture Var
''                                 , ;      // [09]  C   Consulta F3
.T.                                , ;      // [10]  L   Indica se o campo é alteravel
NIL                                , ;      // [11]  C   Pasta do campo
NIL                                , ;      // [12]  C   Agrupamento do campo
NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
NIL                                , ;      // [15]  C   Inicializador de Browse
.F.                                , ;      // [16]  L   Indica se o campo é virtual
NIL                                , ;      // [17]  C   Picture Variavel
NIL                                )        // [18]  L   Indica pulo de linha após o campo


oStruSR8:AddField( ;                        // Ord. Tipo Desc.
'R8_DESPROB'                       , ;      // [01]  C   Nome do Campo
'40'                               , ;      // [02]  C   Ordem
AllTrim( STR0028), ;    // [03]  C   Titulo do campo//'Desconta prazo probatório'
AllTrim( STR0029), ;    // [04]  C   Descricao do campo//'Desconta prazo probatório'
{ STR0030 } , ;        // [05]  A   Array com Help//'Desconta prazo probatório?'
'C'                                , ;      // [06]  C   Tipo do campo
'@!'                               , ;      // [07]  C   Picture
NIL                                , ;      // [08]  B   Bloco de Picture Var
''                                 , ;      // [09]  C   Consulta F3
NIL                                , ;      // [10]  L   Indica se o campo é alteravel
NIL                                , ;      // [11]  C   Pasta do campo
NIL                                , ;      // [12]  C   Agrupamento do campo
{STR0031,STR0032}, ;      // [13]  A   Lista de valores permitido do campo (Combo)//'1=Lista e Prorroga'//'2=Lista e Não Prorroga'
NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
NIL                                , ;      // [15]  C   Inicializador de Browse
.F.                                , ;      // [16]  L   Indica se o campo é virtual
NIL                                , ;      // [17]  C   Picture Variavel
NIL                                )        // [18]  L   Indica pulo de linha após o campo


oStruSR8:AddField( ;                        // Ord. Tipo Desc.
'R8_PROPRAZO'                      , ;      // [01]  C   Nome do Campo
'41'                               , ;      // [02]  C   Ordem
AllTrim( STR0033)   , ;      // [03]  C   Titulo do campo//'Prorrogacao de prazo'
AllTrim( STR0034 )  , ;      // [04]  C   Descricao do campo//'Prorrogacao de prazo'
{ STR0035 }         , ;      // [05]  A   Array com Help//'Prorrogacao de prazo'
'N'                                , ;      // [06]  C   Tipo do campo
'@!'                               , ;      // [07]  C   Picture
NIL                                , ;      // [08]  B   Bloco de Picture Var
''                                 , ;      // [09]  C   Consulta F3
NIL                                , ;      // [10]  L   Indica se o campo é alteravel
NIL                                , ;      // [11]  C   Pasta do campo
NIL                                , ;      // [12]  C   Agrupamento do campo
NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
NIL                                , ;      // [15]  C   Inicializador de Browse
.F.                                , ;      // [16]  L   Indica se o campo é virtual
NIL                                , ;      // [17]  C   Picture Variavel
NIL                                )        // [18]  L   Indica pulo de linha após o campo 

oStruSR8:AddField( ;                        // Ord. Tipo Desc.
'R8_NUMDOC'                       , ;      // [01]  C   Nome do Campo
'42'                               , ;      // [02]  C   Ordem
AllTrim( STR0036)                , ; // [03]  C   Titulo do campo//'Nro. Do Docu'
AllTrim( STR0037 ), ; // [04]  C   Descricao do campo//'Nro. Do Documento'
{ STR0038 } , ;       // [05]  A   Array com Help//'Nro. Do Documento'
'C'                                , ;      // [06]  C   Tipo do campo
'@!'                               , ;      // [07]  C   Picture
NIL                                , ;      // [08]  B   Bloco de Picture Var
''                                 , ;      // [09]  C   Consulta F3
.T.                                , ;      // [10]  L   Indica se o campo é alteravel
NIL                                , ;      // [11]  C   Pasta do campo
NIL                                , ;      // [12]  C   Agrupamento do campo
NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
NIL                                , ;      // [15]  C   Inicializador de Browse
.F.                                , ;      // [16]  L   Indica se o campo é virtual
NIL                                , ;      // [17]  C   Picture Variavel
NIL                                )        // [18]  L   Indica pulo de linha após o campo

oStruSR8:AddField( ;                        // Ord. Tipo Desc.
'R8_ANO'                           , ;      // [01]  C   Nome do Campo
'43'                               , ;      // [02]  C   Ordem
AllTrim( STR0046)          , ; //"Ano do Docum"  [03]  C   Titulo do campo
AllTrim( STR0039 )      , ; // [04]  C   Descricao do campo//'Ano do Documento'
{ STR0040 }             , ;       // [05]  A   Array com Help//'Ano do Documento'
'C'                                , ;      // [06]  C   Tipo do campo
'@!'                               , ;      // [07]  C   Picture
NIL                                , ;      // [08]  B   Bloco de Picture Var
''                                 , ;      // [09]  C   Consulta F3
.T.                                , ;      // [10]  L   Indica se o campo é alteravel
NIL                                , ;      // [11]  C   Pasta do campo
NIL                                , ;      // [12]  C   Agrupamento do campo
NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
NIL                                , ;      // [15]  C   Inicializador de Browse
.F.                                , ;      // [16]  L   Indica se o campo é virtual
NIL                                , ;      // [17]  C   Picture Variavel
NIL                                )        // [18]  L   Indica pulo de linha após o campo


oModel:GetModel( "SR8DETAIL" ):SetOnlyView(.T.)

oStruSRA:SetProperty('*', MVC_VIEW_FOLDER_NUMBER, '1' )

oCalc1 := FWCalcStruct( oModel:GetModel( "VDFC010CALC1") )

oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_SRA', oStruSRA, 'SRAMASTER' )
oView:AddField( 'VIEW_CALC', oCalc1, 'VDFC010CALC1' )
oView:AddGrid(  'VIEW_SR8', oStruSR8, 'SR8DETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 30 ) 
oView:CreateHorizontalBox( 'INFERIOR', 60 )
oView:CreateHorizontalBox( 'INFCALC' , 10 )

oView:SetOwnerView( 'VIEW_SR8', 'INFERIOR' )
oView:SetOwnerView( 'VIEW_SRA', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CALC', 'INFCALC' )

oView:EnableTitleView('VIEW_SRA')
oView:EnableTitleView('VIEW_SR8')

// Desliga a navegacao interna de registros
oView:setUseCursor(.F.)

// Define fechamento da tela
oView:SetCloseOnOk( {||.T.} )


Return oView 
//-------------------------------------------------------------------
/*/ {Protheus.doc} CALCPRO
Regra para carregar os Dados da SRA através do 
parâmetro bLoad da oModel:AddField
@author Everson S P Junior
@since 25/07/2013
@version P11
@params oMdl -> Modelo de dados Com a Field
@Obs a Query SR8 no CALCPRO para carregar os 
calculos manual para os campos  Data Prev.p/vitaliciamento
e Tempo.p/vitaliciamento.
/*/
//-------------------------------------------------------------------
Static Function CALCPRO(oMdl)// nLinha
Local aRet       := {}
Local cTmpSRA    := GetNextAlias()
Local cTmpSR8    := GetNextAlias()
Local cFunc      := SRA->RA_MAT
Local dAdm       := SRA->RA_DTNOMEA
Local nPesoCal   := 0
Local cDesprob   := ''    
Local nTotal   :=0
Local dCalDat
Local nDias
Local nMes  
Local nVDFVIT1  := SuperGetMv('MV_VDFVIT1')


BeginSql alias cTmpSRA
	
	COLUMN RA_DTNOMEA AS DATE	
	SELECT SRA.* FROM %table:SRA%  SRA
	WHERE 
	SRA.RA_FILIAL = %exp:FwxFilial('SRA')%
	AND SRA.RA_MAT = %exp:cFunc% 
	AND SRA.%NotDel%
		
	ORDER BY RA_MAT

EndSql

BeginSql alias cTmpSR8 
	
	COLUMN R8_DATAFIM AS DATE
	COLUMN R8_DATA AS DATE                             
	COLUMN R8_DATAINI AS DATE
	
	SELECT SR8.* FROM %table:SRA%  SRA
	JOIN %table:SR8%  SR8 ON
	SR8.R8_FILIAL = SRA.RA_FILIAL
	AND SR8.R8_MAT = SRA.RA_MAT
	AND SR8.%NotDel%
	JOIN %table:RCM% RCM ON
	RCM.RCM_FILIAL = %exp:FwxFilial('RCM')%
	AND RCM.RCM_TIPO = SR8.R8_TIPOAFA
	AND RCM.RCM_PROVIT <> '3' 
	AND RCM.%NotDel%
	  
	WHERE 
	SRA.RA_FILIAL = %exp:FwxFilial('SRA')%
	AND SRA.RA_MAT = %exp:cFunc% 
	AND SRA.%NotDel%
		
	ORDER BY R8_MAT

EndSql

While !(cTmpSR8)->(EoF())
	nPesoCal:=Posicione("RCM",1,FwxFilial("RCM")+(cTmpSR8)->R8_TIPOAFA,"RCM_DIAVIT")
	cDesprob:=Posicione("RCM",1,FwxFilial("RCM")+(cTmpSR8)->R8_TIPOAFA,"RCM_PROVIT")
    If cDesprob == '1'
    	nTotal += (cTmpSR8)->R8_DURACAO*nPesoCal
    EndIf
    (cTmpSR8)->(DbSkip())
EndDo    

aRet := FwLoadByAlias( oMdl, cTmpSRA )
	
dCalDat    := (dAdm + nVDFVIT1 +	nTotal)
aRet[1][6] := dCalDat //Posição do campo RA_DATVITA
nDias      := (dCalDat - dDatabase)
nMes       := Int(nDias/30)

If nMes < 2
	aRet[1][7]:= ' '+Alltrim(STR(nMes))+STR0041+' e '+Alltrim(STR(nDias-(nMes*30)))+' '+ STR0042 //Posição do campo RA_TEMVITA//' Mês   '//'Dia(s)'
Else
    aRet[1][7]:= Alltrim(STR(nMes))+STR0043+' e '+Alltrim(STR(nDias-(nMes*30)))+' '+ STR0044//' Meses '//'Dia(s)'
EndIf    
    

(cTmpSR8)->(DbCloseArea())
(cTmpSRA)->(DbCloseArea())
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CALCAU
Regra para soma de Totais de dias computados
@author Everson S P Junior
@since 12/07/2013
@version P11
@params oFw -> Modelo de dados completo
/*/
//-------------------------------------------------------------------

Static Function CALCAU(oFw,lPar,cDesprob)
Local lCal     := lPar
Local cSoma := oFW:GetValue( 'SR8DETAIL', 'R8_DESPROB' )

If cSoma <> '1'
	lCal := .F.	
EndIf

Return lCal

//-------------------------------------------------------------------
/*/{Protheus.doc} SelecSR8
Seleciona os dados para o grid 
@author Everson S P Junior
@since 12/07/2013
@version P11
@params
	oMdl -> Modelo de dados Detail.
/*/
//-------------------------------------------------------------------
Static Function SelecSR8( oMdl )
Local aRet       := {}
Local cTmpTrab   := GetNextAlias()
Local cFunc      := SRA->RA_MAT
Local cTpBanco   := AllTrim(Upper(TcGetDb()))
Local cRI6Chave  := ''

If cTpBanco $ "ORACLE/DB2" 
	cRI6Chave	 := "SR8.R8_FILIAL||SR8.R8_MAT||SR8.R8_DATAINI||SR8.R8_TIPOAFA"
Else
	cRI6Chave	 := "SR8.R8_FILIAL+SR8.R8_MAT+SR8.R8_DATAINI+SR8.R8_TIPOAFA"
EndIf


BeginSql alias cTmpTrab
	
	COLUMN R8_DATAFIM AS DATE
	COLUMN R8_DATA AS DATE                             
	COLUMN R8_DATAINI AS DATE
	
	SELECT SR8.*,RI6_NUMDOC R8_NUMDOC ,RI6_ANO R8_ANO FROM %table:SRA%  SRA
	JOIN %table:SR8%  SR8 ON
	SR8.R8_FILIAL = SRA.RA_FILIAL
	AND SR8.R8_MAT = SRA.RA_MAT
	AND SR8.%NotDel%
	JOIN %table:RCM%  RCM ON
	RCM.RCM_FILIAL = %exp:FwxFilial('RCM')%
	AND RCM.RCM_TIPO = SR8.R8_TIPOAFA
	AND RCM.RCM_PROVIT <> '3' 
	AND RCM.%NotDel%                 //01+000002+13011992+001    0
	LEFT JOIN %table:RI6%  RI6 ON //R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPOAFA+STR(R8_DIASEMP)
	RI6.RI6_FILIAL     = %exp:FwxFilial('RI6')% 
	AND RI6.RI6_CHAVE LIKE %exp:cTpBanco%
	AND RI6.RI6_TABORI = 'SR8'
	AND RI6.%NotDel%
	WHERE 
	SRA.RA_FILIAL = %exp:FwxFilial('SRA')%
	AND SRA.RA_MAT = %exp:cFunc% 
	AND SRA.%NotDel%
		
	ORDER BY R8_MAT

EndSql

aRet := FwLoadByAlias( oMdl, cTmpTrab )
(cTmpTrab)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFC010VL
Verifica se o Usuario tem Acesso a Rotina de Acordo com as 
resgras da tabela AX. S103
@author Everson S P Junior
@since 12/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function VDFC010VL()
Local lRet       := .F.
Local nX		 := 0
Local aAllUser   := {}
Local aQuery     := {} 
Local cEmFiMat   := ''
Local cFil 		 := ''
Local cMat       := '' 	
PswOrder(1)
If (PswSeek(__cUserId,.T.))

	aAllUser := PswRet()
    if PswAdmin( , ,RetCodUsr()) == 0 //administrador
        return(.T.)
    EndIf

	If cEmpAnt <> left(aAllUser[1,22],len(cEmpAnt))
		Return(.f.)
	Else
		cEmFiMat := SUBSTR(aAllUser[1,22],len(cEmpAnt)+1,Len(aAllUser[1,22])) 
		dbSelectArea( 'SRA' )
		dbSetOrder( 1 ) 
		cFil := PADR(SUBSTR(cEmFiMat,0001,Len(AllTrim(FwxFilial('SRA'))))+SPACE(12),Len(FwxFilial('SRA')))
		cMat := Alltrim(SUBSTR(cEmFiMat,Len(AllTrim(FwxFilial('SRA')))+1,Len(aAllUser[1,22])))
		If !(SRA->(dbSeek(cFil+cMat)))
			Return(.f.)
		EndIf
	EndIf
EndIf

If !lRet .AND. Empty(SRA->RA_DEMISSA)
   	aQuery := VDFC010QR(cFil)
   	If Len(aQuery) >= 1
		lRet := .T.
   	EndIf  
	TRBRCC->(DbCloseArea())
EndIf

Return lRet
//---------------------------------------------------------------
/*/{Protheus.doc} VDFC010QR
Query para Retorno do Array de Informações da 
tabela Ax.Rcc S103
@author Everson S.P Junior
@since 17/07/13
@version P11 
@return aRet
/*/ 
//-----------------------------------------------------------------

Static Function VDFC010QR(cFil)
Local cQryTmp 	:= ' '
Local cMatRCC		:= ""
Local cMatRCCBLQ	:= ""
Local cDptRCC		:= ""
Local cFunRCC		:= ""
Local aRet    	:= {}
Default cFil 		:= ""

cQryTmp += " SELECT RCC_CONTEU, RCC_FIL "+ CRLF 
cQryTmp += " FROM  " 	+ RetSqlName("RCC") + " RCC, " + CRLF
cQryTmp += " WHERE " + CRLF
cQryTmp += " RCC.RCC_FILIAL  = '"+FwxFilial('RCC')+"' AND "+ CRLF
cQryTmp += " RCC.RCC_CODIGO ='S103' AND RCC_FIL IN ('"+cFil+"','') AND"+ CRLF
cQryTmp += " RCC.D_E_L_E_T_ =' ' "+ CRLF
cQryTmp := ChangeQuery(cQryTmp)
dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'TRBRCC', .F., .T. )

While !TRBRCC->(Eof())
	cMatRCC		:= SUBSTR(TRBRCC->RCC_CONTEU,0081,00070)//matricula liberada
	cMatRCCBLQ	:= SUBSTR(TRBRCC->RCC_CONTEU,0151,00070)//matrícula bloqueada
	cDptRCC		:= SUBSTR(TRBRCC->RCC_CONTEU,0001,0020)//departamento
	cFunRCC		:= SUBSTR(TRBRCC->RCC_CONTEU,0021,00059)//função
	//VERIFICA FUNÇÃO E DEPARTAMENTO
	If SRA->RA_DEPTO $ cDptRCC 
		If (AllTrim(SRA->RA_CODFUNC) $ AllTrim(cFunRCC) .Or. Empty(cFunRCC))
			//VERIFICA MATRICULA
			If (Alltrim(SRA->RA_MAT) $ cMatRCC .Or. Empty(cMatRCC)) .And. !(Alltrim(SRA->RA_MAT) $ cMatRCCBLQ)
				aAdd(aRet,{cDptRCC,cFunRCC,cMatRCC,cMatRCCBLQ,TRBRCC->RCC_FIL})
			EndIf 
		EndIf
	EndIf
 	TRBRCC->(DbSkip())
EndDo	

Return aRet

Static Function SetVld(oModel,oBrowse)
Local lRet  := .F.
oModel:SetValue( "SRAMASTER", "RA_TEMVITA", STR0045 )//'Tempo Prev.p/vitaliciamento'
oBrowse:REFRESH()

Return .T.

