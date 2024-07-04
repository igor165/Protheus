#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM562.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEM562    Ё Autor Ё Flavio  Correa       	      Ё Data Ё 22/12/16 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё ManutenГЦo de Previdencia Complementar - DIRF                			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEM562()                                                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                   			Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC			Ё  Motivo da Alteracao                      Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEM562()

Local oMBrowse
Local cFiltraRh

oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //"PrevidЙncia Complementar"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFiltraRh := CHKRH("GPEM560","SRA","1")
oMBrowse:SetFilterDefault( cFiltraRh )

oMBrowse:Activate()

Return   

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Flavio  Correa  Ё Data Ё22/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM562                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

Local oModel
Local oStructSRA
Local oStructSM9
Local oStructSMU

// Criacao do Objeto de Modelagem de dados da tabela SR4 //
oModel     := MPFormModel():New("GPEM562", NIL, NIL, {|oModel| M562Commit(oModel)})
oModel:SetDescription( OemToAnsi(STR0001)) //"PrevidЙncia Complementar"

// Estrutura de campos do Model //
oStructSRA := FWFormStruct(1, "SRA", { |cCampo| Gpm562SRAStru(cCampo) })
oModel:AddFields("GPEM562_MSRA", NIL, oStructSRA)
oModel:GetModel( "GPEM562_MSRA" ):SetDescription( OemToAnsi(STR0001) ) //"PrevidЙncia Complementar"
oModel:GetModel( "GPEM562_MSRA" ):SetOnlyQuery(.T.)
oModel:GetModel( "GPEM562_MSRA" ):SetOnlyView(.T.)

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Estrutura de campos do Model (SMU) Previdencia Complementar			 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

oStructSMU := FWFormStruct(1, "SMU")          
oModel:AddGrid("GPEM562_MSMU", "GPEM562_MSRA", oStructSMU)
oModel:GetModel( "GPEM562_MSMU" ):SetDescription( OemToAnsi(STR0001) ) //"PrevidЙncia Complementar"
oModel:GetModel( "GPEM562_MSMU" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEM562_MSMU" ):SetNoUpdateLine(.T.)
oModel:GetModel( "GPEM562_MSMU" ):SetNoDeleteLine(.T.)
oModel:SetRelation( "GPEM562_MSMU", { { 'MU_FILIAL', 'xFilial("SMU", SRA->RA_FILIAL)' }, { 'MU_MAT', 'SRA->RA_MAT' } }, SMU->( IndexKey( 1 ) ) )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Estrutura de campos do Model (SM9)									 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oStructSM9 := FWFormModelStruct():New()
M562Str(1,oStructSM9)
oModel:AddGrid("GPEM562_MSM9", "GPEM562_MSMU", oStructSM9 , NIL, NIL, NIL, NIL, {|oGrid,lCopia| LoadSM9(oGrid,lCopia) } )
oModel:GetModel( "GPEM562_MSM9" ):SetDescription( OemToAnsi(STR0001) ) //"PrevidЙncia Complementar"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
oModel:GetModel( "GPEM562_MSM9" ):SetOptional(.T.)
oModel:GetModel( "GPEM562_MSM9" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEM562_MSM9" ):SetNoDeleteLine(.T.)
oModel:SetRelation( "GPEM562_MSM9", { { 'M9_FILIAL', 'xFilial("SM9", SRL->RL_FILIAL)' }, { 'M9_MAT', 'SRL->RL_MAT' } , {'TMP_CODBEN' , "RQ_ORDEM"}, {'TMP_ANO' , 'cAno'}, {'TMP_CODRET' , 'SRL->RL_CODRET'} }, SM9->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey({})

Return( oModel )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Flavio  Correa  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM562                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()

Local oView 
Local oModel
Local oStructSRA
Local oStructSM9
Local oStructSMU

// Vincular o View ao Model //
oModel := FWLoadModel("GPEM562")	

// Criacao da Interface //
oView := FWFormView():New()
oView:SetModel(oModel)

// Criacao do Cabecalho - SRA (Funcionario) //
oStructSRA := FWFormStruct(2, "SRA", { |cCampo| Gpm562SRAStru(cCampo) })
oStructSRA:SetNoFolder()
oView:AddField("GPEM562_VSRA", oStructSRA, "GPEM562_MSRA" )

// Criacao do GRID - SMU Previdencia //
oStructSMU:= FWFormStruct(2, 'SMU')
oStructSMU:RemoveField("MU_MAT")
oView:AddGrid("GPEM562_VSMU", oStructSMU, "GPEM562_MSMU" )


// Criacao do GRID - SM9 PervidЙncia Complementar //
oStructSM9 := FWFormViewStruct():New()
M562Str(2,oStructSM9)
oStructSM9:RemoveField("TMP_MAT")
oStructSM9:RemoveField("TMP_CODRET")
oStructSM9:RemoveField("TMP_ANO")
oStructSM9:RemoveField("TMP_MES")
oStructSM9:RemoveField("TMP_CODFOR")
oStructSM9:RemoveField("TMP_FILIAL")
oView:AddGrid("GPEM562_VSM9", oStructSM9, "GPEM562_MSM9" )

// Desenho da Tela //
oView:CreateHorizontalBox("SRA_HEAD", 17)
oView:CreateHorizontalBox("SMU_GRID", 28)
oView:CreateHorizontalBox("SM9_GRID", 55)


oView:SetOwnerView( "GPEM562_VSRA", "SRA_HEAD" )
oView:SetOwnerView( "GPEM562_VSMU", "SMU_GRID" )
oView:SetOwnerView( "GPEM562_VSM9", "SM9_GRID" )

oView:EnableTitleView( "GPEM562_VSRA", OemToAnsi(STR0002) ) //"FuncionАrio"
oView:EnableTitleView( "GPEM562_VSMU", OemToAnsi(STR0003) ) //"Fornecedores"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
oView:EnableTitleView( "GPEM562_VSM9", OemToAnsi(STR0001) ) //"PrevidЙncia Complementar"

Return oView

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpm562SRAStru	ЁAutorЁ  Flavio  Correa  Ё Data Ё20/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSelecionar os campos para a estrutura do SRA                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM562                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm562SRAStru( cCampo )
	Local lRet := .F.
	
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_MAT*RA_NOME' 
		lRet := .T.
	EndIf
	
Return lRet

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Flavio  Correa  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse.                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM562                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEM562" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.GPEM562" 		OPERATION 4 ACCESS 0				//'Alterar'  

Return aRotina   

//-------------------------------------------------------------------
/*/{Protheus.doc} M562Str
Estrutura da tabela SM8, para model e view
@author Flavio S. Correa
@since 21/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function M562Str(nTipo,oStruct)
Local aArea    := GetArea()
Local bValid   := Nil
Local bWhen    := Nil
Local bRelac   := Nil
Local aTit 		:= {}
Local nI		:= 1


aAdd( aTit, { 'Filial'											,'Filial'										,'TMP_FILIAL'		, "C", FWGETTAMFILIAL		, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )	
aAdd( aTit, { 'Matricula'										,'Matricula'									,'TMP_MAT'			, "C", TamSx3("RA_MAT")[1]	, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )	
aAdd( aTit, { 'Cod Forn.'										,'Cod Forn.'									,'TMP_CODFOR'		, "C", 2					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )	
aAdd( aTit, { 'MЙs'												,'MЙs'											,'TMP_MES'			, "C", 2					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )	
aAdd( aTit, { 'MЙs'												,'MЙs'											,'TMP_DESMES'		, "C", 10					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )	
aAdd( aTit, { 'Cod. RetenГЦo'									,'Cod. RetenГЦo'								,'TMP_CODRET'		, "C", 4					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )	
aAdd( aTit, { 'Ano'												,'Ano'											,'TMP_ANO'			, "C", 4					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Dt. Pagto'										,'Dt. Pagto'									,'TMP_DTPGTO'		, "D", 8					, 0 ,"@!"					,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'FAPI'											,'FAPI'											,'TMP_VALM2'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )	
aAdd( aTit, { '13o-FAPI'										,'13o-FAPI'										,'TMP_VALM5'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Prev. Privada'									,'Prev. Privada'								,'TMP_VALM'	  		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Prev. Privada 13╨'								,'Prev. Privada 13╨'							,'TMP_VALM1'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )	
aAdd( aTit, { '13o-Exigib. Susp.-FAPI'							,'13o-Exigib. Susp.-FAPI'						,'TMP_VAL9D'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Exigib. Susp.-FAPI'								,'Exigib. Susp.-FAPI'							,'TMP_VAL9A'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Prev. Pr.Exigib.Susp'							,'Prev. Pr.Exigib.Susp'							,'TMP_VAL9'			, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Prev. Exigib.Susp 13'							,'Prev. Exigib.Susp 13'							,'TMP_VAL91'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )	
aAdd( aTit, { '13o-Fundo Prev.Serv.PЗblico'						,'13o-Fundo Prev.Serv.PЗblico'					,'TMP_VALM6'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { '13o-Contr.Ente pЗblico patroc.'					,'13o-Contr.Ente pЗblico patroc.'				,'TMP_VALM7'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { '13o-Exigib. Susp.-Fundo Prev.Serv.PЗblico'		,'13o-Exigib. Susp.-Fundo Prev.Serv.PЗblico'	,'TMP_VAL9E'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { '13o-Exigib. Susp.-Contr. Ente pЗbl. patroc.'		,'13o-Exigib. Susp.-Contr. Ente pЗbl. patroc.'	,'TMP_VAL9F'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Exigib. Susp.-Fundo Prev.Serv.PЗblico'			,'Exigib. Susp.-Fundo Prev.Serv.PЗblico'		,'TMP_VAL9B'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Exigib. Susp.-Contr. Ente pЗblico patroc.'		,'Exigib. Susp.-Contr. Ente pЗblico patroc.'	,'TMP_VAL9C'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Fundo Prev.Serv.PЗbl'							,'Fundo Prev.Serv.PЗbl'							,'TMP_VALM3'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		
aAdd( aTit, { 'Contr.Ente pЗbl.patroc'							,'Contr.Ente pЗbl.patroc'						,'TMP_VALM4'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )		

	
For nI := 1 To Len(aTit)
	If nTipo = 1
		oStruct:AddField( ;
			aTit[nI][1]           , ;              // [01] Titulo do campo
			aTit[nI][2]           , ;              // [02] ToolTip do campo
			aTit[nI][3]           , ;              // [03] Id do Field
			aTit[nI][4]           , ;              // [04] Tipo do campo
			aTit[nI][5]           , ;              // [05] Tamanho do campo
			aTit[nI][6]           , ;              // [06] Decimal do campo
			aTit[nI][15]          , ;              // [07] Code-block de validaГЦo do campo
			aTit[nI][14]          , ;              // [08] Code-block de validaГЦo When do campo
			aTit[nI][9]           , ;              // [09] Lista de valores permitido do campo
			.F.                   , ;              // [10] Indica se o campo tem preenchimento obrigatСrio
			aTit[nI][12]          , ;              // [11] Code-block de inicializacao do campo
			NIL                   , ;              // [12] Indica se trata-se de um campo chave
			Nil                   , ;              // [13] Indica se o campo nЦo pode receber valor em uma operaГЦo de update.
			aTit[nI][13] )          		           // [14] Indica se o campo И virtual
	Else
		oStruct:AddField( 				      ;
		   		aTit[nI][3]                 , ;              // [01] Campo
				alltrim(strzero(nI+3,2))  	, ;              // [02] Ordem
				aTit[nI][1]                 , ;              // [03] Titulo
				aTit[nI][1]                 , ;              // [04] Descricao
				NIL                    		, ;              // [05] Help
				aTit[nI][11]                , ;              // [06] Tipo do campo   COMBO, Get ou CHECK
				aTit[nI][7]                 , ;              // [07] Picture
				                       		, ;              // [08] PictVar
				                  			, ;              // [09] F3
				aTit[nI][10]   	            , ;              // [10] Editavel
				                       		, ;              // [11] Folder
				                       		, ;              // [12] Group
				aTit[nI][9]                 , ;              // [13] Lista Combo
				                            , ;              // [14] Tam Max Combo
				                            , ;              // [15] Inic. Browse
				aTit[nI][13])                                // [16] Virtual
			
	EndIf

Next nI

RestArea( aArea )

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadSM9
Load do model SM9
@author Flavio S. Correa
@since 21/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadSM9(oGrid,lCopia)
Local aRet       	:= {}
Local aArea      	:= GetArea()                          
Local nI			:= 1
Local cAliasTmp		:= GetNextAlias()
Local oSMU			:= oGrid:GetModel("GPEM562_MSMU"):GetModel("GPEM562_MSMU")
Local cFor			:= oSMU:getvalue("MU_CODFOR")
Local aMeses		:= {"Janeiro", "Fevereiro", "MarГo", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro","Dezembro" }  //"Janeiro", "Fevereiro"... "Dezembro"
Local aPos			:= {"M2","M5","M","M1","9D","9A","9","91","M6","M7","9E","9F","9B","9C","M3","M4"}
Local nPosIni		:= 8
Local nPos			:= 0

BEGINSQL ALIAS cAliasTmp
	column M9_DTPGTO as date
	SELECT *
	FROM %table:SM9% SM9
	WHERE SM9.%notDel% 
	AND M9_FILIAL = %exp:SRL->RL_FILIAL%
	AND M9_MAT = %exp:SRL->RL_MAT%
	AND M9_CODFOR = %exp:cFor%
	AND M9_ANO	 = %exp:cAno%
	AND M9_CODRET = %exp:SRL->RL_CODRET%
ENDSQL

For nI := 1 To 12
	Aadd(aRet, {nI, {SRL->RL_FILIAL,SRL->RL_MAT,cFor,strzero(nI,2),aMeses[nI],SRL->RL_CODRET,cAno,ctod(" /  / "),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } )	
Next nI

While !(cAliasTmp)->(Eof())
	nPos := aScan(aPos,{ |x| x==Alltrim((cAliasTmp)->M9_TIPOREN)})
	aRet[Val((cAliasTmp)->M9_MES)][2][nPosIni+nPos] += (cAliasTmp)->M9_VALOR
	aRet[Val((cAliasTmp)->M9_MES)][2][8] := (cAliasTmp)->M9_DTPGTO
	(cAliasTmp)->(dbSkip())
EndDo                      
(cAliasTmp)->(dbCloseArea())

RestArea( aArea )				
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} M562Commit
Grava Model
@author Flavio S. Correa
@since 21/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function M562Commit(oModel)
Local aArea		:= GetArea()
Local aTabS073	:= {}
Local oSMU		:= oModel:GetModel( 'GPEM562_MSMU' )
Local oTMP		:= oModel:GetModel( 'GPEM562_MSM9' )
Local nLenSMU	:= oSMU:Length()
Local nLenTMP	:= oTMP:Length()
Local aRend		:= {"M2","M5","M","M1","9D","9A","9","91","M6","M7","9E","9F","9B","9C","M3","M4"}
Local nX		:= 1
Local nY		:= 1
Local nZ		:= 1
Local nPos		:= 0
Local cCodFor := ""
Local cCNPJ	:= ""
Local cNomeEmp:= ""

fRetTab( @aTabS073, "S073", , , , , .T., , .T. )

dbSelectArea("SM9")
SM9->(dbSetOrder(1))

If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	For nX := 1 To nLenSMU
		oSMU:GoLine( nX )
		For nY := 1 To nLenTMP
			oTMP:GoLine( nY )
			If oTMp:IsUpdated()
				For nZ := 1 To Len(aRend)
					//M9_FILIAL+M9_MAT+M9_CODBEN+M9_CODRET+M9_ANO+M9_MES+M9_TIPOREN
					If SM9->(dbSeek(oTMP:GetValue("TMP_FILIAL")+oTMP:GetValue("TMP_MAT")+oTMP:GetValue("TMP_CODFOR")+oTMP:GetValue("TMP_CODRET")+cANo+oTMP:GetValue("TMP_MES")+padr(aRend[nZ],2)    ) )
						RecLock("SM9",.F.)
							SM9->M9_VALOR := oTMP:GetValue("TMP_VAL"+aRend[nZ])
							SM9->M9_DTPGTO:= oTmp:GetValue("TMP_DTPGTO")
						SM8->(msUnlock())
					Else
						cCodFor:= oSMU:GetValue("MU_CODFOR")
						nPos 	:= aScan(aTabS073,{|x| x[5] == cCodFor })
						If nPos > 0
							cCNPJ := aTabS073[nPos][6]
							cNomeEmp := aTabS073[nPos][7]
						Else
							cCNPJ := ""
							cNomeEmp := ""
						EndIf
						If oTMP:GetValue("TMP_VAL"+aRend[nZ]) > 0
							RecLock("SM9",.T.)
								SM9->M9_FILIAL 	:= oTMP:GetValue("TMP_FILIAL")
								SM9->M9_MAT		:= oTMP:GetValue("TMP_MAT")
								SM9->M9_CODFOR 	:= oTMP:GetValue("TMP_CODFOR")
								SM9->M9_CODRET	:= oTMP:GetValue("TMP_CODRET")
								SM9->M9_MES		:= oTMP:GetValue("TMP_MES")
								SM9->M9_ANO	 	:= cAno
								SM9->M9_TIPOREN := aRend[nZ]
								SM9->M9_VALOR  	:= oTMP:GetValue("TMP_VAL"+aRend[nZ])
								SM9->M9_DTPGTO 	:= oTmp:GetValue("TMP_DTPGTO")
								SM9->M9_CNPJ		:= cCNPJ
								SM9->M9_NOMEEMP	:= cNomeEmp
							SM8->(msUnlock())
						EndIf
					EndIf
				Next nZ
			EndIf
		Next nY
	Next nX
EndIf

RestArea(aArea)
Return( .T. )
