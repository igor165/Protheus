#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA036.CH"

STATIC lIsRussia	:= cPaisLoc == "RUS"
Static lExisCPC31	:= NIL
/*/{Protheus.doc} ATFA036

Rotina de Cancelamento de Múltiplas Baixas de Ativo

@author marylly.araujo
@since 25/03/2014
@version 1.0
/*/

Function ATFA036M()
Local lMostraLan	:= .F.
Local lAglutina		:= .F.
Local lCtbOnline	:= .F.
Local nVisualiza	:= 2

/*
 * Carrega Pergunta Baixa de Ativo
 */
Pergunte("AFA036",.F.)
SetKey( VK_F12, { || Pergunte("AFA036",.T.) })

lMostraLan	:= MV_PAR01 == 1
lAglutina	:= MV_PAR02 == 1
lCtbOnline	:= MV_PAR03 == 1
nVisualiza	:= MV_PAR04

Return Nil

/*{Protheus.doc} ModelDef

Definição do Modelo de Dados u da Rotina de Baixa de Ativos

@author marylly.araujo
@since 25/03/2014
@version 1.0
*/

Static Function ModelDef()
Local oModel	:= Nil

/*
 * Cria o objeto do Modelo de Dados
 */
Local oStrTip	:= FWFormStruct(1, 'FN7' )	//Tipos
Local oStruPar	:= FWFormModelStruct():New()

oStrTip:AddField(		;
STR0046					,;	// [01] Titulo do campo		//"Lote"
STR0046					,;	// [02] ToolTip do campo	//"Lote"
"LOTE"					,;	// [03] Id do Field
"C"						,;	// [04] Tipo do campo
TamSX3("FN6_LOTE")[1]	,;	// [05] Tamanho do campo
0						,;	// [06] Decimal do campo
{ || .T. }				,;	// [07] Code-block de validação do campo
						,;	// [08] Code-block de validação When do campo
						,;	// [09] Lista de valores permitido do campo
.F.						)	// [10] Indica se o campo tem preenchimento obrigatório

oStrTip:AddField(STR0007,STR0008 , 'OK', 'L', 1, 0, { |oModel| AF036MARK() } , , {}, .F., , .F., .F., .F., , )//'Baixa?'#//'Seleção'

oStruPar:AddField(	;
STR0049				,;	// [01] Titulo do campo		//"Filial De"
STR0049				,;	// [02] ToolTip do campo	//"Filial De"
"FILIALDE"			,;	// [03] Id do Field
"C"					,;	// [04] Tipo do campo
FWSizeFilial()		,;	// [05] Tamanho do campo
0					,;	// [06] Decimal do campo
{ || .T. }			,;	// [07] Code-block de validação do campo
					,;	// [08] Code-block de validação When do campo
					,;	// [09] Lista de valores permitido do campo
.F.					)	// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	;
STR0050				,;	// [01] Titulo do campo		//"Filial Até"
STR0050				,;	// [02] ToolTip do campo	//"Filial Até"
"FILIALATE"			,;	// [03] Id do Field
"C"					,;	// [04] Tipo do campo
FWSizeFilial()		,;	// [05] Tamanho do campo
0					,;	// [06] Decimal do campo
{ || .T. }			,;	// [07] Code-block de validação do campo
					,;	// [08] Code-block de validação When do campo
					,;	// [09] Lista de valores permitido do campo
.F.					)	// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(		;
STR0051					,;	// [01] Titulo do campo		//"Grupo de Bens De"
STR0051					,;	// [02] ToolTip do campo	//"Grupo de Bens De"
"GRUPODE"				,;	// [03] Id do Field
"C"						,;	// [04] Tipo do campo
TamSX3(IIf(lIsRussia, "FM1_CODE", "NG_GRUPO"))[1]	,;	// [05] Tamanho do campo
0						,;	// [06] Decimal do campo
{ || .T. }				,;	// [07] Code-block de validação do campo
						,;	// [08] Code-block de validação When do campo
						,;	// [09] Lista de valores permitido do campo
.F.						)	// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(		;
STR0052					,;	// [01] Titulo do campo		//"Grupo de Bens Até"
STR0052					,;	// [02] ToolTip do campo	//"Grupo de Bens Até"
"GRUPOATE"				,;	// [03] Id do Field
"C"						,;	// [04] Tipo do campo
TamSX3(IIf(lIsRussia, "FM1_CODE", "NG_GRUPO"))[1]	,;	// [05] Tamanho do campo
0						,;	// [06] Decimal do campo
{ || .T. }				,;	// [07] Code-block de validação do campo
						,;	// [08] Code-block de validação When do campo
						,;	// [09] Lista de valores permitido do campo
.F.						)// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(		;
STR0053					,;	// [01] Titulo do campo		//"Código de Bem De"
STR0053					,;	// [02] ToolTip do campo	//"Código de Bem De"
"CODIGODE"				,;	// [03] Id do Field
"C"						,;	// [04] Tipo do campo
TamSX3("N1_CBASE")[1]	,;	// [05] Tamanho do campo
0						,;	// [06] Decimal do campo
{ || .T. }				,;	// [07] Code-block de validação do campo
						,;	// [08] Code-block de validação When do campo
						,;	// [09] Lista de valores permitido do campo
.F.						)	// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(		;
STR0054					,;	// [01] Titulo do campo		//"Código de Bem Até"
STR0054					,;	// [02] ToolTip do campo	//"Código de Bem Até"
"CODIGOATE"				,;	// [03] Id do Field
"C"						,;	// [04] Tipo do campo
TamSX3("N1_CBASE")[1]	,;	// [05] Tamanho do campo
0						,;	// [06] Decimal do campo
{ || .T. }				,;	// [07] Code-block de validação do campo
						,;	// [08] Code-block de validação When do campo
						,;	// [09] Lista de valores permitido do campo
.F.						)	// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(		;
STR0055					,;	// [01] Titulo do campo		//"Item de Bem De"
STR0055					,;	// [02] ToolTip do campo	//"Item de Bem De"
"ITEMDE"				,;	// [03] Id do Field
"C"						,;	// [04] Tipo do campo
TamSX3("N1_ITEM")[1]	,;	// [05] Tamanho do campo
0						,;	// [06] Decimal do campo
{ || .T. }				,;	// [07] Code-block de validação do campo
						,;	// [08] Code-block de validação When do campo
						,;	// [09] Lista de valores permitido do campo
.F.						)	// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(		;
STR0056					,;	// [01] Titulo do campo		//"Item de Bem Até"
STR0056					,;	// [02] ToolTip do campo	//"Item de Bem Até"
"ITEMATE"				,;	// [03] Id do Field
"C"						,;	// [04] Tipo do campo
TamSX3("N1_ITEM")[1]	,;	// [05] Tamanho do campo
0						,;	// [06] Decimal do campo
{ || .T. }				,;	// [07] Code-block de validação do campo
						,;	// [08] Code-block de validação When do campo
						,;	// [09] Lista de valores permitido do campo
.F.						)	// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	;
STR0057				,;	// [01] Titulo do campo		//"Data Aquisição De"
STR0057				,;	// [02] ToolTip do campo	//"Data Aquisição De"
"DATADE"			,;	// [03] Id do Field
"D"					,;	// [04] Tipo do campo
8					,;	// [05] Tamanho do campo
0					,;	// [06] Decimal do campo
{ || .T. }			,;	// [07] Code-block de validação do campo
					,;	// [08] Code-block de validação When do campo
					,;	// [09] Lista de valores permitido do campo
.T.					)	// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(	;
STR0058				,;	// [01] Titulo do campo		//"Data Aquisição Até"
STR0058				,;	// [02] ToolTip do campo	//"Data Aquisição Até"
"DATAATE"			,;	// [03] Id do Field
"D"					,;	// [04] Tipo do campo
8					,;	// [05] Tamanho do campo
0					,;	// [06] Decimal do campo
{ || .T. }			,;	// [07] Code-block de validação do campo
					,;	// [08] Code-block de validação When do campo
					,;	// [09] Lista de valores permitido do campo
.T.					)	// [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField(					;
STR0059								,;	// [01] Titulo do campo
STR0059								,;	// [02] ToolTip do campo
'BOTAO'          					,;	// [03] Id do Field
'BT'             					,;	// [04] Tipo do campo
1               					,;	// [05] Tamanho do campo
0                					,;	// [06] Decimal do campo
{ |oMdl| AF036LOADM( oMdl ), .T. }	)	// [07] Code-block de validação do campo

oStruPar:AddField(					;
STR0146								,;	// [01] Titulo do campo
STR0146								,;	// [02] ToolTip do campo
'BOTAO2'          					,;	// [03] Id do Field
'BT'             					,;	// [04] Tipo do campo
1               					,;	// [05] Tamanho do campo
0                					,;	// [06] Decimal do campo
{ |oMdl| AF036MMARK( oMdl ), .T. }	)	// [07] Code-block de validação do campo


/*
 * Criação do Modelo de Dados
 */
oModel := MPFormModel():New('ATFA036M', /*bPreValidacao*/, {|| AF036VlOut(oModel)}/*bPosValidacao*/, /*bGravacao*/ { |oModel| AF036GRVM(oModel) }, /*bCancel*/ )

oModel:AddFields('PARAMETROS',/*cOwner*/,oStruPar,/*bPreVld*/,/*bPosVld*/,{||}/*bLoad*/)

/*
 * Adiciona ao modelo uma estrutura de formulário de edição por grid
 */
oModel:AddGrid('FN7TIPO','PARAMETROS',oStrTip)//,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/{|oModel| AF036LOADM(oModel)})

/*
 * Descrição
 */
oModel:SetDescription(STR0001) // "Baixa de Ativos"
oModel:GetModel('PARAMETROS'):SetDescription( STR0060 )	// "Parâmetros de Filtro de Ativos para Baixa "
oModel:GetModel('FN7TIPO'  ):SetDescription( STR0032 )	// 'Tipos de Ativos'

/*
 * Desabilita a Gravação automatica dos Model FN6MASTER / FN7TIPO / FN7VALOR
 */
oModel:GetModel( 'PARAMETROS'):SetOnlyQuery ( .T. )
oModel:GetModel( 'FN7TIPO'	):SetOnlyQuery ( .T. )

oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef

Definição da Interface da Rotina de Baixa de Ativos (Cancelamento de Múltiplas Baixas)

@author marylly.araujo
@since 24/03/2014
@version 1.0
/*/

Static Function ViewDef()
/*
 * Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
 */
Local oModel	:= FWLoadModel( 'ATFA036M' )
Local oView 	:= Nil

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStrPar		:= FWFormViewStruct():New()
Local oStrTipos	:= FWFormStruct(2, 'FN7' )	//Tipos

oStrTipos:AddField( 'OK'     ,'00',STR0007,STR0007,, 'Check' ,,,,,,,,,,,, ) //'Baixa?'#//'Baixa?'

oStrTipos:AddField(		;
"FN7_FILORI"			,;	// [01] Id do Field
"00"					,;	// [02] Ordem
RetTitle("FN7_FILORI")	,;	// [03] Titulo do campo		//"Lote"
RetTitle("FN7_FILORI")	,;	// [04] ToolTip do campo	//"Lote"
						,;	// [05] Help
"G"						,;	// [06] Tipo do campo
"@!"					,;	// [07] Picture
						,;	// [08] PictVar
''						)	// [09] F3

oStrTipos:AddField(	;
"LOTE"				,;	// [01] Id do Field
"00"				,;	// [02] Ordem
"Lote"				,;	// [03] Titulo do campo		//"Lote"
"Lote"				,;	// [04] ToolTip do campo	//"Lote"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
''					)	// [09] F3

oStrPar:AddField(	;
"FILIALDE"			,;	// [01] Id do Field
"01"				,;	// [02] Ordem
STR0049				,;	// [03] Titulo do campo		//"Filial De"
STR0049				,;	// [04] ToolTip do campo	//"Filial De"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
'XM0'				)	// [09] F3

oStrPar:AddField(	;
"FILIALATE"			,;	// [01] Id do Field
"02"				,;	// [02] Ordem
STR0050				,;	// [03] Titulo do campo		//"Filial Até"
STR0050				,;	// [04] ToolTip do campo	//"Filial Até"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
'XM0'				)	// [09] F3

oStrPar:AddField(	;
"GRUPODE"			,;	// [01] Id do Field
"03"				,;	// [02] Ordem
STR0051				,;	// [03] Titulo do campo		//"Grupo de Bens De"
STR0051				,;	// [04] ToolTip do campo	//"Grupo de Bens De"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
IIf(lIsRussia, "FM1", "SNG")				)	// [09] F3

oStrPar:AddField(	;
"GRUPOATE"			,;	// [01] Id do Field
"04"				,;	// [02] Ordem
STR0052				,;	// [03] Titulo do campo		//"Grupo de Bens Até"
STR0052				,;	// [04] ToolTip do campo	//"Grupo de Bens Até"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
IIf(lIsRussia, "FM1", "SNG")				)	// [09] F3

oStrPar:AddField(	;
"CODIGODE"			,;	// [01] Id do Field
"05"				,;	// [02] Ordem
STR0053				,;	// [03] Titulo do campo		//"Código de Bem De"
STR0053				,;	// [04] ToolTip do campo	//"Código de Bem De"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
'SN1'				)	// [09] F3

oStrPar:AddField(	;
"CODIGOATE"			,;	// [01] Id do Field
"06"				,;	// [02] Ordem
STR0054				,;	// [03] Titulo do campo		//"Código de Bem Até"
STR0054				,;	// [04] ToolTip do campo	//"Código de Bem Até"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
'SN1'				)	// [09] F3

oStrPar:AddField(	;
"ITEMDE"			,;	// [01] Id do Field
"07"				,;	// [02] Ordem
STR0055				,;	// [03] Titulo do campo		//"Item de Bem De"
STR0055				,;	// [04] ToolTip do campo	//"Item de Bem De"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
''					)	// [09] F3

oStrPar:AddField(	;
"ITEMATE"			,;	// [01] Id do Field
"08"				,;	// [02] Ordem
STR0056				,;	// [03] Titulo do campo		//"Item de Bem Até"
STR0056				,;	// [04] ToolTip do campo	//"Item de Bem Até"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
''					)	// [09] F3

oStrPar:AddField(	;
"DATADE"			,;	// [01] Id do Field
"09"				,;	// [02] Ordem
STR0057				,;	// [03] Titulo do campo		//"Data Aquisição De"
STR0057				,;	// [04] ToolTip do campo	//"Data Aquisição De"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
''					)	// [09] F3

oStrPar:AddField(	;
"DATAATE"			,;	// [01] Id do Field
"10"				,;	// [02] Ordem
STR0058				,;	// [03] Titulo do campo		//"Data Aquisição Até"
STR0058				,;	// [04] ToolTip do campo	//"Data Aquisição Até"
					,;	// [05] Help
"G"					,;	// [06] Tipo do campo
"@!"				,;	// [07] Picture
					,;	// [08] PictVar
''					)	// [09] F3

oStrPar:AddField(	;
'BOTAO'			,;	// [01] Campo
"11"				,;	// [02] Ordem
STR0061			,;	// [03] Titulo
STR0061			,;	// [04] Descricao
NIL					,;	// [05] Help
'BT'				)	// [06] Tipo do campo   COMBO, Get ou CHECK

oStrPar:AddField(	;
'BOTAO2'			,;	// [01] Campo
"12"				,;	// [02] Ordem
STR0146			,;	// [03] Titulo
STR0146			,;	// [04] Descricao
NIL					,;	// [05] Help
'BT'				)	// [06] Tipo do campo   COMBO, Get ou CHECK

/*
 * Cria o objeto de View
 */
oView := FWFormView():New()

/*
 * Define qual o Modelo de dados será utilizado
 */
oView:SetModel(oModel)
oView:AddField('FORM_PARAM'	,oStrPar	,'PARAMETROS')	// Parâmetros Múltiplas Baixas
oView:AddGrid('GRID_TIPOS'	,oStrTipos	,'FN7TIPO'	)	// Tipos de Ativo

/*
 * Remove Campos não Usados - Tipos de Ativos
 */
oStrTipos:RemoveField( 'FN7_FILORI' )
oStrTipos:RemoveField( 'FN7_STATUS' )
oStrTipos:RemoveField( 'FN7_VLRESI' )

/*
 * Criar "box" horizontal para receber algum elemento da view
 */
oView:CreateHorizontalBox( 'BOXPARAM',		35) //Cabeçalho
oView:CreateHorizontalBox( 'BOXTIPOS',		65) //Tipos de Ativos

/*
 * Relaciona o ID da View com o "box" para exibicao
 */
oView:SetOwnerView('FORM_PARAM'		,'BOXPARAM' )	// Tipos de Ativo
oView:SetOwnerView('GRID_TIPOS'		,'BOXTIPOS' )	// Tipos de Ativo

/*
 * Habilita a exibição do título do submodelo PARAMETROS
 */
oView:EnableTitleView('FORM_PARAM'	, STR0062 ) //'Tipos de Ativos'
/*
 * Bloqueia a inclusão de novas linhas
 */
oView:SetNoInsertLine('GRID_TIPOS')

/*
 * Bloqueia a exclusão de linhas do grid
 */
oView:SetNoDeleteLine('GRID_TIPOS')

/*
 * Habilita a exibição do titulo
 */
oView:EnableTitleView('GRID_TIPOS'	,STR0032 ) //'Ativos Baixados'

/*
 * Acrescentando regra de auto-incremento no campo de Item nos Grids
 */
oView:AddIncrementField( 'GRID_TIPOS'	,'FN7_ITEM' )

/*
 * Fecha a tela apos a gravação
 */
oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} AF036LOADM

Função que retorna a carga da grid de Tipos de Ativos

@author marylly.araujo
@since 24/03/2014
@version 1.0
/*/
Static Function AF036LOADM()
Local oModel		:= FWModelActive()
Local oModelPar		:= oModel:GetModel("PARAMETROS")
Local oModelFN7		:= oModel:GetModel("FN7TIPO")
Local oView			:= FWViewActive()
Local aArea			:= GetArea()
Local aSN1Area		:= {}
Local aSN3Area		:= {}
Local aSN4Area		:= {}
Local aFN6Area		:= {}
Local aFN7Area		:= {}
Local nLine			:= 0
Local cQry			:= ''
Local cAls			:= GetNextAlias()
Local nQtdLines		:= oModelFN7:Length()
Local nCountLine	:= 0

DbSelectArea('SN1')
aSN1Area	:= SN1->(GetArea())
DbSelectArea('SN3')
aSN3Area	:= SN3->(GetArea())
DbSelectArea('FN6')
aFN6Area	:= FN6->(GetArea())
DbSelectArea('FN7')
aFN7Area	:= FN7->(GetArea())
DbSelectArea('SN4')
aSN4Area	:= SN4->(GetArea())


oModelFN7:SetNoInsertLine(.F.)

//Na nova carga do Grid, as linhas existentes são apagadas.
If oModelFN7:CanClearData() 
	oModelFN7:ClearData(.T.)
	oView:Refresh()
EndIf

cQry := "SELECT " + CRLF
cQry += "FN6.FN6_LOTE "		+ CRLF
cQry += ",SN1.N1_DESCRIC "	+ CRLF
cQry += ",FN7.FN7_FILIAL "	+ CRLF
cQry += ",FN7.FN7_CODBX "	+ CRLF
cQry += ",FN7.FN7_ITEM "	+ CRLF
cQry += ",FN7.FN7_CBASE "	+ CRLF
cQry += ",FN7.FN7_CITEM "	+ CRLF
cQry += ",FN7.FN7_TIPO "	+ CRLF
cQry += ",FN7.FN7_TPSALD "	+ CRLF
cQry += ",FN7.FN7_SEQ "		+ CRLF
cQry += ",FN7.FN7_SEQREA "	+ CRLF
cQry += ",FN7.FN7_MOTIVO "	+ CRLF
cQry += ",FN7.FN7_DTBAIX "	+ CRLF
cQry += ",FN7.FN7_VLATU "	+ CRLF
cQry += ",FN7.FN7_VLDEPR "	+ CRLF
cQry += ",FN7.FN7_VLBAIX "	+ CRLF
cQry += ",FN7.FN7_PERCBX "	+ CRLF
cQry += ",FN7.FN7_STATUS "	+ CRLF
cQry += ",FN7.FN7_FILORI "	+ CRLF
cQry += ",FN7.FN7_VLRESI "	+ CRLF
cQry += ",FN7.FN7_MOEDA "	+ CRLF
cQry += " FROM " + RetSqlName("FN7") + " FN7 " + CRLF
cQry += " INNER JOIN " + RetSqlName("FN6") + " FN6 ON FN7.FN7_FILIAL = FN6.FN6_FILIAL AND FN7.FN7_CODBX = FN6.FN6_CODBX AND FN7.FN7_CBASE = FN6.FN6_CBASE AND FN7.FN7_CITEM = FN6.FN6_CITEM " + CRLF
cQry += " INNER JOIN " + RetSqlName("SN1") + " SN1 ON FN7.FN7_FILIAL = SN1.N1_FILIAL AND FN7.FN7_CBASE = SN1.N1_CBASE AND FN7.FN7_CITEM = SN1.N1_ITEM " + CRLF
cQry += " INNER JOIN " + RetSqlName("SN4") + " SN4 ON SN4.N4_FILIAL = FN7.FN7_FILIAL AND SN4.N4_CBASE = FN7_CBASE AND SN4.N4_ITEM = FN7.FN7_CITEM AND SN4.N4_TIPO = FN7.FN7_TIPO" + CRLF
If lIsRussia .And. !EMPTY(oModelPar:GetValue("GRUPOATE"))
	cQry += " INNER JOIN " + RetSqlName("FM1") + " FM1 ON FM1.FM1_CODE = SN1.N1_DEPGRP " + CRLF
EndIf
cQry += " WHERE " + CRLF
cQry += " FN7.FN7_FILIAL BETWEEN '" + XFilial("FN7",oModelPar:GetValue("FILIALDE")) + "' AND '" + XFilial("FN7",oModelPar:GetValue("FILIALATE")) + "' " + CRLF
cQry += " AND FN7.FN7_CBASE BETWEEN '" + oModelPar:GetValue("CODIGODE") + "' AND '" + oModelPar:GetValue("CODIGOATE") + "' " + CRLF
cQry += " AND FN7.FN7_CITEM BETWEEN '" + oModelPar:GetValue("ITEMDE") + "' AND '" + oModelPar:GetValue("ITEMATE") + "' " + CRLF
cQry += " AND SN1.N1_AQUISIC BETWEEN '" + DTOS(oModelPar:GetValue("DATADE")) + "' AND '" + DTOS(oModelPar:GetValue("DATAATE")) + "' " + CRLF
cQry += " AND FN6.FN6_STATUS = '1' " + CRLF
cQry += " AND FN7.FN7_STATUS = '1' "  + CRLF
cQry += " AND FN7.FN7_MOEDA = '01' "  + CRLF	
If lIsRussia .And. !EMPTY(oModelPar:GetValue("GRUPOATE"))
	cQry += " AND FM1.D_E_L_E_T_ = ' ' "  + CRLF
	cQry += " AND FM1.FM1_FILIAL = SN1.N1_FILIAL "  + CRLF
	cQry += " AND FM1.FM1_CODE BETWEEN '" + oModelPar:GetValue("GRUPODE") + "' AND '" + oModelPar:GetValue("GRUPOATE") + "' "  + CRLF
ElseIf !EMPTY(oModelPar:GetValue("GRUPOATE"))
	cQry += " AND SN1.N1_GRUPO BETWEEN '" + oModelPar:GetValue("GRUPODE") + "' AND '" + oModelPar:GetValue("GRUPOATE") + "' "  + CRLF
EndIf
cQry += " AND SN4.N4_OCORR NOT IN ('03', '04') " + CRLF
cQry += " AND FN7_MOTIVO != ('18') " + CRLF
cQry += " AND FN7.D_E_L_E_T_ = ' ' " + CRLF
cQry += " AND FN6.D_E_L_E_T_ = ' ' " + CRLF
cQry += " AND SN1.D_E_L_E_T_ = ' ' " + CRLF
cQry += " AND SN4.D_E_L_E_T_ = ' ' " + CRLF

cQry += " GROUP BY FN6.FN6_LOTE " + CRLF
cQry += " ,SN1.N1_DESCRIC " + CRLF
cQry += " ,FN7.FN7_FILIAL " + CRLF
cQry += " ,FN7.FN7_CODBX " + CRLF
cQry += " ,FN7.FN7_ITEM " + CRLF
cQry += " ,FN7.FN7_CBASE " + CRLF
cQry += " ,FN7.FN7_CITEM " + CRLF
cQry += " ,FN7.FN7_TIPO " + CRLF
cQry += " ,FN7.FN7_TPSALD " + CRLF
cQry += " ,FN7.FN7_SEQ " + CRLF
cQry += " ,FN7.FN7_SEQREA " + CRLF
cQry += " ,FN7.FN7_MOTIVO " + CRLF
cQry += " ,FN7.FN7_DTBAIX " + CRLF
cQry += " ,FN7.FN7_VLATU " + CRLF
cQry += " ,FN7.FN7_VLDEPR " + CRLF
cQry += " ,FN7.FN7_VLBAIX " + CRLF
cQry += " ,FN7.FN7_PERCBX " + CRLF
cQry += " ,FN7.FN7_STATUS " + CRLF
cQry += " ,FN7.FN7_FILORI " + CRLF
cQry += " ,FN7.FN7_VLRESI " + CRLF
cQry += " ,FN7.FN7_MOEDA " + CRLF

cQry += " ORDER BY FN7_FILORI,FN7_CBASE,FN7_CITEM,FN7_TIPO " + CRLF

cQry := ChangeQuery( cQry )

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAls , .T. , .F.)
TcSetField(cAls,'FN7_DTBAIX','D')
/*
 * Cancelamento de Múltiplas Baixas
 */
While (cAls)->(!Eof())
	nLine := oModelFN7:AddLine()
	If !EMPTY( (cAls)->FN6_LOTE )
		oModelFN7:SetValue("LOTE",		 (cAls)->FN6_LOTE, .T.)	// FN7_FILIAL
	EndIf

	oModelFN7:SetValue("FN7_FILIAL"	,(cAls)->FN7_FILIAL	,.T.)	// FN7_FILIAL0
	oModelFN7:SetValue("FN7_CODBX"	,(cAls)->FN7_CODBX	,.T.)	// FN7_CODBX
	oModelFN7:SetValue("FN7_ITEM"	,(cAls)->FN7_ITEM	,.T.)	// FN7_ITEM
	oModelFN7:SetValue("FN7_CBASE"	,(cAls)->FN7_CBASE	,.T.)	// FN7_CBASE
	oModelFN7:SetValue("FN7_CITEM"	,(cAls)->FN7_CITEM	,.T.)	// FN7_CITEM
	oModelFN7:SetValue("FN7_DESCRI"	,(cAls)->N1_DESCRIC	,.T.)	// FN7_DESCRI
	oModelFN7:SetValue("FN7_TIPO"	,(cAls)->FN7_TIPO	,.T.) 	// FN7_TIPO
	oModelFN7:SetValue("FN7_TPSALD"	,(cAls)->FN7_TPSALD	,.T.)	// FN7_TPSALD
	oModelFN7:SetValue("FN7_SEQ"	,(cAls)->FN7_SEQ	,.T.)	// FN7_SEQ
	oModelFN7:SetValue("FN7_SEQREA"	,(cAls)->FN7_SEQREA	,.T.)	// FN7_SEQREA
	oModelFN7:SetValue("FN7_MOTIVO"	,(cAls)->FN7_MOTIVO	,.T.)	// FN7_MOTIVO
	oModelFN7:SetValue("FN7_DTBAIX"	,(cAls)->FN7_DTBAIX	,.T.)	// FN7_DTBAIX
	oModelFN7:SetValue("FN7_VLATU"	,(cAls)->FN7_VLATU	,.T.)	// FN7_VLATU
	oModelFN7:SetValue("FN7_VLDEPR"	,(cAls)->FN7_VLDEPR	,.T.)	// FN7_VLDEPR
	oModelFN7:SetValue("FN7_VLBAIX"	,(cAls)->FN7_VLBAIX	,.T.)	// FN7_VLBAIX
	oModelFN7:SetValue("FN7_PERCBX"	,(cAls)->FN7_PERCBX	,.T.)	// FN7_PERCBX
	oModelFN7:SetValue("FN7_STATUS"	,(cAls)->FN7_STATUS	,.T.)	// FN7_STATUS
	oModelFN7:SetValue("FN7_FILORI"	,(cAls)->FN7_FILORI	,.T.)	// FN7_FILORI
	oModelFN7:SetValue("FN7_MOEDA"	,(cAls)->FN7_MOEDA	,.T.)	// FN7_MOEDA
	oModelFN7:SetValue("FN7_VLRESI"	,(cAls)->FN7_VLRESI	,.T.)	// FN7_VLRESI
	(cAls)->(DbSkip())
EndDo

If nLine == 0
	Help(" ",1,"ATLOADCanM" ,,STR0063,1,0)	
EndIf

(cAls)->(DbCloseArea())

oModelFN7:SetNoInsertLine(.T.)
oModelFN7:SetLine(1)

RestArea(aArea)
RestArea(aSN1Area)
RestArea(aSN3Area)
RestArea(aSN4Area)
RestArea(aFN6Area)
RestArea(aFN7Area)

Return Nil
 

/*/{Protheus.doc} AF036MARK

Função que retorna a carga da grid de Tipos de Ativos

@author marylly.araujo
@since 24/03/2014
@version 1.0
/*/
Static Function AF036MARK()
Local oModel			:= FWModelActive()
Local oView			:= FWViewActive()
Local oModelTipo		:= oModel:GetModel('FN7TIPO')			// Carrega Model TIPO
Local lRet				:= .T.
Local nX				:= 0
Local aSaveLines 		:= FWSaveRows()
Local lMarca			:= oModelTipo:GetValue("OK")
Local cBaixa			:= oModelTipo:GetValue("FN7_CODBX") 

For nX:= 1 to oModelTipo:Length()
	oModelTipo:GoLine(nX)
	If oModelTipo:GetValue("FN7_CODBX") == cBaixa
		oModelTipo:LoadValue("OK",lMarca)
	EndIF
Next


FWRestRows(aSaveLines)
If oView != Nil
	oView:Refresh()
EndIf

Return lRet

/*/{Protheus.doc} AF036GRVM

Função para gravação dos dados do cancelamento de baixas de vários ativos ao mesmo tempo, selecionados na MarkBrowse

@author marylly.araujo
@since 28/03/2014
@version 1.0
/*/
Function AF036GRVM( oModel )
Local oModelTipo	:= oModel:GetModel('FN7TIPO')	// Carrega Model VALOR
Local lOk			:= .T.
Local cFilFN6		:= ""
Local cFilFN7		:= ""
Local nContAtivo	:= 0
Local nQtdBaixas	:= 0
Local nHdlPrv		:= 0
Local cLoteAtf	:= LoteCont("ATF")
Local cArquivo	:= ''
Local nTotal		:= 0
Local cChvBx		:= ""
Local cFilBkp		:= cFilAnt
Local cFilAux		:= ""
Local nX			:= 0
Local nPrxReg		:= 0

FN6->(DbSetOrder(1)) // Filial + Código de Baixa
FN7->(DbSetOrder(1)) // Filial + Código de Baixa

//-------------------------------------------------------------------------------
// Caso a baixa tenha gerado NF com mais de um ativo, inclui os demais no modelo
// para cancelamento da baixa de todos, possibilitando a exclusao da NF
//-------------------------------------------------------------------------------
A036MAdAtv(oModelTipo)

nQtdBaixas := oModelTipo:Length()

If lExisCPC31 == Nil
	lExisCPC31 := SN1->(Fieldpos("N1_BLQDEPR")) > 0 .And. cPaisLoc == "BRA" //CPC31, VERIFICA SE O CAMPO EXISTE NA BASE E SE ? DA LOCALIDADE DO BRASIL
EndIF

//-----------------------------------------
// Realiza a baixa
//-----------------------------------------

BEGIN TRANSACTION

For nContAtivo := 1 To nQtdBaixas
	oModelTipo:GoLine( nContAtivo )
	If oModelTipo:GetValue("OK")

		//-----------------------------------
		// Tratamento para mudança de filial
		//-----------------------------------
		If cFilAux <> oModelTipo:GetValue("FN7_FILORI")
			cFilAnt := oModelTipo:GetValue("FN7_FILORI")
			cFilAux := oModelTipo:GetValue("FN7_FILORI")
			cFilFN6 := oModelTipo:GetValue("FN7_FILIAL")
			cFilFN7 := oModelTipo:GetValue("FN7_FILIAL")

			If nHdlPrv <= 0
				nHdlPrv := HeadProva(cLoteAtf,"ATFA036",Substr(cUsername,1,6),@cArquivo)
			Endif
		EndIf
		If IsBlind()  // ajuste para correto posicionamento quando executado via robo advpr
			FN6->(DbSetOrder(1)) // Filial + Código de Baixa
			FN7->(DbSetOrder(1)) // Filial + Código de Baixa
		EndIF
		If FN6->(DbSeek( cFilFN6 + oModelTipo:GetValue("FN7_CODBX") ) )
			While FN6->(!Eof()) .AND. cFilFN6 + oModelTipo:GetValue("FN7_CODBX") == FN6->FN6_FILIAL + FN6->FN6_CODBX .And. cChvBx <> cFilFN6 + oModelTipo:GetValue("FN7_CODBX")
				If FN7->(DbSeek(cFilFN7 + FN6->FN6_CODBX ) )
					While FN7->(!Eof()) .AND. cFilFN7 + FN6->FN6_CODBX == FN7->FN7_FILIAL + FN7->FN7_CODBX
						If FN7->FN7_MOEDA == '01'
							lOk := AF036Cance(FN6->FN6_CBASE,FN6->FN6_CITEM,FN7->FN7_TIPO,FN7->FN7_TPSALD,FN6->FN6_DTBAIX,FN7->FN7_SEQ,FN7->FN7_MOTIVO,@nHdlPrv,@nTotal,FN7->FN7_CODBX,nil,FN6->FN6_NUMNF,FN6->FN6_SERIE,FN6->FN6_CLIENT,FN6->FN6_LOJA)

							If lOk
								FN7->(RecLock("FN7",.F.))
								FN7->FN7_STATUS := '2'
								FN7->(MsUnLock())
							Else
								Exit
							EndIf
						Else
							If lOk
								FN7->(RecLock("FN7",.F.))
								FN7->FN7_STATUS := '2'
								FN7->(MsUnLock())
							EndIf
						EndIf

						If lOk //Cancelamento da gravação bem volta a ter depreciacao.
							If lExisCPC31
								SN1->(RecLock("SN1"))
								SN1->N1_BLQDEPR := ""  
								SN1->(MsUnlock())
							EndIF
						Endif
						
						FN7->(DbSkip())
					EndDo
				EndIf

				If lOk
					FN6->(RecLock("FN6",.F.))
					FN6->FN6_STATUS := '2'
					FN6->(MsUnLock())
					/*
					Caso a baixa tenha sido em lote, verifica se todos os ativos desse lote tambem tiveram a baixa cancelada e, sendo este o caso, 
					cancela o lote. */
					AF036CaFN8(FN6->FN6_FILIAL,FN6->FN6_LOTE)
				Else
					Exit
				EndIf

			FN6->(DbSkip())
			EndDo
			cChvBx := cFilFN6 + oModelTipo:GetValue("FN7_CODBX")

			//-----------------------------------------------------
			// Identifica qual o proximo registro a ser processado
			//-----------------------------------------------------
			For nX := nContAtivo+1 To nQtdBaixas
				If oModelTipo:GetValue("OK",nX)
					nPrxReg := nX
					Exit
				EndIf
			Next nX

			//------------------------
			// Contabiliza por filial
			//------------------------
			If (nContAtivo+1) > nQtdBaixas .Or. nPrxReg == 0  .Or. oModelTipo:GetValue("FN7_FILORI",nPrxReg) != cFilAux
				If nHdlPrv > 0 .And. ( nTotal > 0 )
					RodaProva(nHdlPrv, nTotal)
					cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,mv_par01 == 1,mv_par02 == 1)
				Endif
				nHdlPrv := 0
				nTotal  := 0
			EndIf
			nPrxReg := 0
		Else
			lOk := .F.
		EndIf

		If !lOk
			Exit
		EndIf

	EndIf
Next nContAtivo

If !lOk
	DisarmTransaction()
	oModel:SetErrorMessage("ATFA36M","FN7_CODBX","FN7TIPO","FN7_CODBX","GRVCANMUL",STR0064) // "Cancelamento de Baixas cancelado por inconsistências."
EndIf

END TRANSACTION

cFilAnt := cFilBkp

Return lOk

/*/{Protheus.doc} AF036GRVM

Função para gravação dos dados do cancelamento de baixas de vários ativos ao mesmo tempo, selecionados na MarkBrowse

@author marylly.araujo
@since 28/03/2014
@version 1.0
/*/
Function AF036MMARK( oMdl )

Local oModel			:= FWModelActive()
Local oView			:= FWViewActive()
Local oModelTipo		:= oModel:GetModel('FN7TIPO')			// Carrega Model TIPO
Local nX				:= 0
Local aSaveLines 		:= FWSaveRows()
Local lMarca			:= oModelTipo:GetValue("OK")

For nX:= 1 to oModelTipo:Length()
	oModelTipo:GoLine(nX)
	lMarca := oModelTipo:GetValue("OK")
	oModelTipo:LoadValue("OK",!lMarca)
Next

FWRestRows(aSaveLines)
If oView != Nil
	oView:Refresh()
EndIf

Return .T.

/*/{Protheus.doc}AF036VlOut

Verifica se os bens geraram nota e se os demais itens da nota estao selecionados
para cancelamento. Caso nao estejam, avisa o usuario que o sistema os cancelara

@author TOTVS
@since  22/12/2016
@version 12
/*/
Function AF036VlOut(oModel)
Local oModelFN7	:= oModel:GetModel("FN7TIPO")
Local lRet		:= .T.
Local nX		:= 0
Local cCodBaixa	:= ""
Local cAliasQry	:= ""
Local cNumNF	:= ""
Local cNumSerie	:= ""
Local cMsgAtv	:= ""
Local lMsgAtvNF	:= .F.

If !IsBlind()
	For nX := 1 To oModelFN7:Length()

		oModelFN7:GoLine(nX)

		If oModelFN7:GetValue("OK")			

			cCodBaixa := oModelFN7:GetValue("FN7_CODBX")

			//------------------------
			// Verifica se gerou nota
			//------------------------
			FN6->(DBSetOrder(1)) //FN6_FILIAL+FN6_CODBX
			If FN6->(DBSeek(XFilial("FN6")+cCodBaixa)) .And. FN6->FN6_GERANF == "1" .And. !Empty(FN6->FN6_NUMNF) .And. !Empty(FN6->FN6_SERIE) 

				cNumNF		:= FN6->FN6_NUMNF
				cNumSerie	:= FN6->FN6_SERIE
				cFilOri		:= FN6->FN6_FILORI

				//------------------------------------
				// Verifica se tem mais itens na nota
				//------------------------------------
				cAliasQry := GetNextAlias()
				BeginSQL Alias cAliasQry
				SELECT R_E_C_N_O_
				FROM %Table:FN6%
				WHERE	FN6_FILORI	= %Exp:cFilOri%		AND
						FN6_NUMNF	= %Exp:cNumNF%		AND
						FN6_SERIE	= %Exp:cNumSerie%	AND
						FN6_GERANF	= '1'				AND
						FN6_STATUS	= '1'				AND
						%NotDel%
				EndSQL

				//------------------------------------
				//Verifica se os itens estao marcados
				//------------------------------------
				While (cAliasQry)->(!Eof())

					FN6->(DBGoTo((cAliasQry)->R_E_C_N_O_))

					If oModelFN7:SeekLine({{"FN7_CODBX",FN6->FN6_CODBX}}) 

						If !oModelFN7:GetValue("OK")
							lMsgAtvNF := .T.
							Exit
						EndIf

					Else

						lMsgAtvNF := .T.
						Exit

					EndIf

				(cAliasQry)->(DBSkip())
				EndDo

				(cAliasQry)->(DBCloseArea())

				If lMsgAtvNF
					Exit
				EndIf

			EndIf

		EndIf

	Next nX

	If lMsgAtvNF
		lRet := MsgNoYes(STR0151,STR0149) //"Há baixas com mais de um ativo por nota fiscal, o sistema cancelará a baixa dos ativos presentes na nota fiscal. Deseja prosseguir?"###"Atenção"
	EndIf

	If !lRet
		oModel:SetErrorMessage("",,oModel:GetId(),"","AF036VlOut",STR0150) //"Baixa cancelada pelo utilizador."
	EndIf

EndIf

Return lRet

/*/{Protheus.doc}A036MAdAtv

Adiciona no modelo os demais ativos que fazem parte da nota para possibilitar o cancelamento

@author TOTVS
@since  22/12/2016
@version 12
/*/
Function A036MAdAtv(oModelFN7)
Local nX		:= 0
Local cCodBaixa	:= ""
Local cAliasQry	:= ""
Local cNumNF	:= ""
Local cNumSerie	:= ""

For nX := 1 To oModelFN7:Length()

	oModelFN7:GoLine(nX)

	If oModelFN7:GetValue("OK")

		cCodBaixa := oModelFN7:GetValue("FN7_CODBX")

		//------------------------
		// Verifica se gerou nota
		//------------------------
		FN6->(DBSetOrder(1)) //FN6_FILIAL+FN6_CODBX
		If FN6->(DBSeek(XFilial("FN6")+cCodBaixa)) .And. FN6->FN6_GERANF == "1" .And. !Empty(FN6->FN6_NUMNF) .And. !Empty(FN6->FN6_SERIE) 

			cNumNF		:= FN6->FN6_NUMNF
			cNumSerie	:= FN6->FN6_SERIE
			cFilOri		:= FN6->FN6_FILORI

			//------------------------------------
			// Verifica se tem mais itens na nota
			//------------------------------------
			cAliasQry := GetNextAlias()
			BeginSQL Alias cAliasQry
			SELECT R_E_C_N_O_
			FROM %Table:FN6%
			WHERE	FN6_FILORI	= %Exp:cFilOri%		AND
					FN6_NUMNF	= %Exp:cNumNF%		AND
					FN6_SERIE	= %Exp:cNumSerie%	AND
					FN6_GERANF	= '1'				AND
					FN6_STATUS	= '1'				AND
					%NotDel%
			EndSQL

			//------------------------------------
			//Verifica se os itens estao marcados
			//------------------------------------
			While (cAliasQry)->(!Eof())

				FN6->(DBGoTo((cAliasQry)->R_E_C_N_O_))

				If oModelFN7:SeekLine({{"FN7_CODBX",FN6->FN6_CODBX}})

					If !oModelFN7:GetValue("OK")
						oModelFN7:SetValue("OK",.T.)
					EndIf

				Else

					oModelFN7:SetNoInsertLine(.F.)

					FN7->(DBSetOrder(1)) //FN7_FILIAL+FN7_CODBX+FN7_ITEM
					If FN7->(DBSeek(XFilial("FN7")+FN6->FN6_CODBX))

						While FN7->(!Eof()) .And. FN7->FN7_CODBX == FN6->FN6_CODBX

							If FN7->FN7_MOEDA == "01"

								oModelFN7:AddLine()

								If !Empty( FN6->FN6_LOTE )
									oModelFN7:SetValue("LOTE", FN6->FN6_LOTE, .T.)
								EndIf

								oModelFN7:SetValue("OK"			,.T.				,.T.)	// Mark
								oModelFN7:SetValue("FN7_FILIAL"	,FN7->FN7_FILIAL	,.T.)	// FN7_FILIAL
								oModelFN7:SetValue("FN7_CODBX"	,FN7->FN7_CODBX		,.T.)	// FN7_CODBX
								oModelFN7:SetValue("FN7_ITEM"	,FN7->FN7_ITEM		,.T.)	// FN7_ITEM
								oModelFN7:SetValue("FN7_CBASE"	,FN7->FN7_CBASE		,.T.)	// FN7_CBASE
								oModelFN7:SetValue("FN7_CITEM"	,FN7->FN7_CITEM		,.T.)	// FN7_CITEM
								oModelFN7:SetValue("FN7_TIPO"	,FN7->FN7_TIPO		,.T.) 	// FN7_TIPO
								oModelFN7:SetValue("FN7_TPSALD"	,FN7->FN7_TPSALD	,.T.)	// FN7_TPSALD
								oModelFN7:SetValue("FN7_SEQ"	,FN7->FN7_SEQ		,.T.)	// FN7_SEQ
								oModelFN7:SetValue("FN7_SEQREA"	,FN7->FN7_SEQREA	,.T.)	// FN7_SEQREA
								oModelFN7:SetValue("FN7_MOTIVO"	,FN7->FN7_MOTIVO	,.T.)	// FN7_MOTIVO
								oModelFN7:SetValue("FN7_DTBAIX"	,FN7->FN7_DTBAIX	,.T.)	// FN7_DTBAIX
								oModelFN7:SetValue("FN7_VLATU"	,FN7->FN7_VLATU		,.T.)	// FN7_VLATU
								oModelFN7:SetValue("FN7_VLDEPR"	,FN7->FN7_VLDEPR	,.T.)	// FN7_VLDEPR
								oModelFN7:SetValue("FN7_VLBAIX"	,FN7->FN7_VLBAIX	,.T.)	// FN7_VLBAIX
								oModelFN7:SetValue("FN7_PERCBX"	,FN7->FN7_PERCBX	,.T.)	// FN7_PERCBX
								oModelFN7:SetValue("FN7_STATUS"	,FN7->FN7_STATUS	,.T.)	// FN7_STATUS
								oModelFN7:SetValue("FN7_FILORI"	,FN7->FN7_FILORI	,.T.)	// FN7_FILORI
								oModelFN7:SetValue("FN7_MOEDA"	,FN7->FN7_MOEDA		,.T.)	// FN7_MOEDA
								oModelFN7:SetValue("FN7_VLRESI"	,FN7->FN7_VLRESI	,.T.)	// FN7_VLRESI

							EndIf

						FN7->(DBSkip())
						EndDo

						oModelFN7:SetNoInsertLine(.T.)
						oModelFN7:SetLine(1)

					EndIf

				EndIf

			(cAliasQry)->(DBSkip())
			EndDo

			(cAliasQry)->(DBCloseArea())

		EndIf

	EndIf

Next nX

Return
