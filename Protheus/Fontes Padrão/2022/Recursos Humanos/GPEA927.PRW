#include 'Protheus.ch'
#Include 'fwmvcdef.ch'    
#include 'GPEA927.CH'      

//Integração com o TAF
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )  
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cVerTrab		:= "2.2"
Static cVerGPE		:= ""
Static cVersEnvio	:= ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ GPEA927  ³ Autor ³ Alessandro Santos                 ³ Data ³ 15/01/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Informacoes de Funcionarios Temporarios (RBW)         					³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA927()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alessandro S³15/01/2014³00000000823/2014³Inclusao da rotina para atender a Fase 2    ³±±
±±³            ³          ³          TIFBQF³eSocial, Cadastro de Funcionarios Temporario³±±  
±±³Alessandro S³24/01/2014³00000000823/2014³Ajuste na validacao dos funcionarios para   ³±±
±±³            ³          ³          TIFBQF³considerar o Vinculo Empregaticio..         ³±±
±±³Alessandro S³24/01/2014³00000000823/2014³Ajuste para considerar vinculo empregaticio ³±±
±±³            ³          ³          TIFBQF³306 e removidas validacoes de Fase 2 eSocial³±±
±±³Alessandro S³28/01/2014³00000000823/2014³Ajuste para apresentar corretamente a descri³±±
±±³            ³          ³          TIFBQF³cao da rotina.                              ³±±    
±±³Gustavo M.  ³01/06/2014³			 TPHIYY³Ajuste para uso da tela centralizadora.		³±±
±±³Christiane V³02/07/2015³          TSMUY2³Adaptações para versão 2.0 do eSocial       ³±±
±±³Mariana M.  ³15/09/2015³          TTIWMQ³Ajuste na função ModelDef,onde sistema está ³±±
±±³            ³          ³                ³carregando o modelo incorreto para abertura ³±±
±±³            ³          ³                ³da tela. Ajustado para que busque oModel e  ³±±
±±³            ³          ³                ³nao oMdlRBW									³±±
±±³Raquel Hager³24/08/2016³TVTOQD          ³Remoção do uso do parâmetro MV_INTTAF para  ³±±
±±³            ³          ³                ³release 12.1.7.							    ³±±
±±³MArcia Moura³23/06/2017³DRHESOCP-470    ³Inclusao no novo controle de eSocial        ³±±			    
±±³Oswaldo L   ³23/06/2017³DRHESOCP-439    ³Correção variaveis não declaradas no fonte  ³±±			    
±±³Oswaldo L   ³04/08/2017³DRHESOCP-755    ³Replica ajustes e-social feit apenas na 12  ³±±
±±|Claudinei S.|11/09/2017|    DRHESOCP-729 |Incluída chamada para a nova tela da pror- |±±
±±|            |          |                 |rogação dos temporários leiaute 2.3.       |±±
±±|Claudinei S.|14/09/2017|   DRHESOCP-1018 |Consistência do leiaute 2.3 para os func.  |±±
±±|            |          |                 |temporários.                               |±±
±±|Marcos Cout.|23/11/2017|   DRHESOCP-2010 |Caso o lIntTaf esteja setado com FALSE(.F.)|±±
±±|            |          |                 |o sistema não deverá verificar a filial de |±±
±±|            |          |                 |envio ao TAF.                              |±±
±±|Cecília Carv|08/01/2018|DRHESOCP-2682    |Ajuste para geração de contrato intermiten-|±±
±±|            |          |                 |te - evento S-2200.                        |±±
±±|Cecília Carv|15/02/2018|DRHESOCP-2493    |Implementação do campo RBW_LOCT para gerar |±±
±±|            |          |                 |dados na tag <localTrabDom> - eventos      |±±
±±|            |          |                 |S-2200/2206.                               |±±
±±|Cecília Carv|03/05/2018|DRHESOCP-4497    |Ajuste para permitir efetuar manutenção com|±±
±±|            |          |                 |parâmmetro MV_RHTAF desabilitado.          |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GPEA927()

Local oMBrowse
Local cFiltraRh  := ""
Local cTrabVincu := fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|304|306" //Trabalhador com vinculo

If lIntTAF .And. FindFunction("fVersEsoc") .And. FindFunction("ESocMsgVer")
	fVersEsoc("S2200", .F.,,, @cVersEnvio, @cVerGPE)			
	If !lMiddleware .And. cVerGPE <> cVersEnvio .And. (cVerGPE >= "9.0" .Or. cVersEnvio >= "9.0")
		If ESocMsgVer(.F., /*cEvento*/, cVerGPE, cVersEnvio)
			lIntTaf := .F.
		Else
			Return ()
		EndIf
	EndIf
EndIf
    
oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0002)) //Temporários

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cFiltraRH	:= ChkRh( "GPEA927" , "SRA" , "1" )
If IsInCallStack("GPEA927")	
	cFiltraRH += If(!Empty(cFiltraRH)," .AND. ", " ")
	cFiltraRh += "RA_TPCONTR == '2'"
	cFiltraRh += " .AND. RA_CATEFD $ '" + cTrabVincu + "'"
	cFiltraRh += " .AND. (Empty(RA_DEMISSA) .OR. DToC(RA_DEMISSA) >= '" + DToC(dDataBase) + "')"		
EndIf

oMBrowse:SetFilterDefault(cFiltraRh)
oMBrowse:SetLocate()
GpLegMVC(@oMBrowse)

oMBrowse:ExecuteFilter(.T.)

oMBrowse:Activate()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ Alessandro Santos     ³ Data ³ 15/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Menu Funcional                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA927'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA927'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0007)  Action 'VIEWDEF.GPEA927'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Alessandro Santos     ³ Data ³ 15/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para o Cadastro de  ³±±
±±³          ³Funcionarios Temporarios (RBW)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ModelDef()

Local oMdlRBW
Local bAvalCampo	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|"}
Local oStruSRA 	  	:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRBW 	  	:= FWFormStruct(1, 'RBW', /*bAvalCampo*/,/*lViewUsado*/)
Local bPosValid  	:= {|oMdlRBW| Gp927PosVal(oMdlRBW)}
Local bCommit		:= {|oMdlRBW| f927Comm(oMdlRBW)}
oMdlRBW := MPFormModel():New('GPEA927', /*bPreValid */, bPosValid, bCommit, /*bCancel*/)

oMdlRBW:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

oMdlRBW:AddGrid( 'RBWDETAIL', 'SRAMASTER', oStruRBW, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oMdlRBW:SetRelation('RBWDETAIL', {{'RBW_FILIAL', 'xFilial("RBW",SRA->RA_FILIAL)'}, {'RBW_MAT', 'RA_MAT'}}, RBW->(IndexKey(1)))
oMdlRBW:GetModel('RBWDETAIL'):SetUniqueLine({'RBW_FILIAL','RBW_MAT'})
oMdlRBW:GetModel('RBWDETAIL'):SetMaxLine(1)

//Permite grid sem dados
oMdlRBW:GetModel('RBWDETAIL'):SetOptional(.T.)
oMdlRBW:GetModel('RBWDETAIL'):SetNoInsertLine(.T.)
oMdlRBW:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlRBW:GetModel('SRAMASTER'):SetOnlyQuery(.T.)

// Adiciona a descricao do Modelo de Dados
oMdlRBW:SetDescription(OemToAnsi(STR0013))  //"Cadastro de Funcionarios Temporarios"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlRBW:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0003)) // "Funcionários"
oMdlRBW:GetModel('RBWDETAIL'):SetDescription(OemToAnsi(STR0002)) // "Temporários"

oMdlRBW:SetActivate( { |oModel| Gp927Init(oModel,oModel:GetOperation()) } )
oMdlRBW:SetVldActivate( { |oModel| Gp927VlMdl(oModel, oModel:GetOperation(), lIntTAF) } )

Return oMdlRBW

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Alessandro Santos     ³ Data ³ 15/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizador de dados do Cadastro de Funcionários Temporários³±±
±±³          ³ (RBW)                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ViewDef()

Local oView
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|"}
Local oModel   := FWLoadModel('GPEA927')
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRBW := FWFormStruct(2, 'RBW')
Local bProrrog := {|| MsAguarde( { || Iif(Gp927VlMdl(oModel, oModel:GetOperation(), @lIntTAF), GPEA927A(4, lIntTAF), "")})}

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')
oStruSRA:SetNoFolder()

oView:AddGrid('VIEW_RBW', oStruRBW, 'RBWDETAIL')

oStruRBW:RemoveField("RBW_MAT")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 16)
oView:CreateHorizontalBox('INFERIOR', 84)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RBW', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0003)) // "Funcionário"
oView:EnableTitleView('VIEW_RBW', OemToAnsi(STR0002)) // "Temporários"

oView:SetCloseOnOk({ || .T. })		//Desabilita botão "Salvar e Criar Novo"

If ( ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2200", .F.,,,@cVerTrab,@cVerGPE),)

If Empty(cVerGPE)
	cVerGPE := cVerTrab
EndIf

If SR8->( ColumnPos("R8_TPPROC")) > 0 .And. cVerGPE > "2.2"
	oView:addUserButton(OemToAnsi(STR0021),"MAGIC_BMP", bProrrog, OemToAnsi(STR0021),, {/*MODEL_OPERATION_INSERT,*/MODEL_OPERATION_UPDATE} ) //"Prorrogação Contrato"
Endif

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Gp927Init  ³ Autor ³ Leandro Drumond       ³ Data ³ 24/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega matricula na grid.                                  s³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp927Init(oMdl,nOperation)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp927Init(oMdl,nOperation)

Local oGridRBW   := oMdl:GetModel('RBWDETAIL') 

If nOperation == MODEL_OPERATION_UPDATE
	oGridRBW:SetValue("RBW_MAT",SRA->RA_MAT)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Gp927VlMdl  ³ Autor ³ Claudinei Soares     ³ Data ³ 14/09/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação do Model                                           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp927VlMdl(oMdl,nOperation)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = lRet                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp927VlMdl(oMdl, nOperation, lIntTAF)

	Local lRet			:= .T.
    Local cVerTaf		:= StrTran(StrTran(SuperGetMv("MV_TAFVLES",, "2.4"), "_", "."), "0", "", 1, 2)

	Default nOperation	:= 0
	Default lIntTAF		:= .T.

    // RECEBE A VERSÃO DO TAF.
    cVerTaf := StrTran(Iif(cVerTaf == "2.4.01", "2.4", cVerTaf), "S.1", "9")

	If lIntTAF
		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
			lRet := If (ExistFunc('fVersEsoc' ), fVersEsoc( "S2200", .F.,,, @cVerTrab, @cVerGPE), .T.)
			If lRet
				lRet := If (ExistFunc('fVersEsoc'), fVersEsoc( "S2100", .F.,,, @cVerTrab, @cVerGPE), lRet)
			Endif
		Endif
		
		If Empty(cVerTrab)
			cVerTrab := "2.2"
		Endif
		
		If Empty(cVerGPE)
			cVerGPE := cVerTrab
		EndIf

	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp927PosVal ³ Autor ³ Alessandro Santos     ³ Data ³ 15/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do Cadastro de Funcionarios Temporarios        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp927PosVal( oMdlRFX )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRFX = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Gp927PosVal( oMdl )

Local aArea      := GetArea()
Local oMdl       := FWModelActive()
Local oGridRBW   := oMdl:GetModel('RBWDETAIL') 
Local nOperation := oMdl:GetOperation()
Local lRetorno   := .T.

If !oGridRBW:IsDeleted() .And. cVerTrab < "9.0.00" .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
	If Empty(oMdl:GetValue('RBWDETAIL','RBW_TPCONT'))
    	Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0033) + FWX3Titulo("RBW_TPCONT") + OemToAnsi(STR0034), 2 , 0 , , , , , , { OemToAnsi(STR0035) } ) 
    	lRetorno := .F.
    ElseIf Empty(oMdl:GetValue('RBWDETAIL','RBW_TPINSC'))
        Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0033) + FWX3Titulo("RBW_TPINSC") + OemToAnsi(STR0034), 2 , 0 , , , , , , { OemToAnsi(STR0035) } ) 
        lRetorno := .F.
    ElseIf Empty(oMdl:GetValue('RBWDETAIL','RBW_INSC'))
	    Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0033) + FWX3Titulo("RBW_INSC") + OemToAnsi(STR0034), 2 , 0 , , , , , , { OemToAnsi(STR0035) } )
        lRetorno := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRetorno  
           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp927When ³ Autor ³ Alessandro Santos     ³ Data ³ 15/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificacao de When para Cadastro de Funcionarios Temporarios³±± 
±±³          ³ Campo RBW_MATSUB e RBW_CPFSUB.                               ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp927When()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function fGp927When()

Local aSaveArea:= GetArea()
Local lRetorno := .F.

//Ativa campos se Motivo = 1
If FwFldGet("RBW_MOTIVO") == '1'
	lRetorno := .T.
EndIf 

RestArea(aSaveArea)

Return lRetorno 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp927Valid³ Autor ³ Alessandro Santos     ³ Data ³ 15/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacoes dos campos de Cadastro de Funcionarios Temporarios³±± 
±±³          ³ Campo RBW_MATSUB e RBW_CPFSUB.                               ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp927Valid()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function fGp927Valid(cCampo)

Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|309" //Trabalhador com vinculo
Local aSaveArea		:= GetArea()
Local lRetorno		:= .T.
Local cCPFs			:= ""
Local cCPF2 		:= ""
Local cCPF3			:= ""
Local cCPF4			:= ""
Local cCPF5			:= ""
Local cCPF6			:= ""
Local cCPF7 		:= ""
Local cCPF8			:= ""
Local cCPF9			:= ""
Local aCPFs			:= {}
Local cCMP1			:= ""
Local oMdl   		:= FwModelActive()
Local nC			:= 0

oMdl:Activate()

cCPFS 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPFSUB')
cCPF2 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF2')
cCPF3 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF3')
cCPF4 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF4')
cCPF5 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF5')
cCPF6 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF6')
cCPF7 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF7')
cCPF8 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF8')
cCPF9 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF9')

aCPFs := {cCPFS,cCPF2,cCPF3,cCPF4,cCPF5,cCPF6,cCPF7,cCPF8,cCPF9}

cCMP1 := Substr(cCampo,8,1)

If cCMP1 == "S"
	cCMP1 := "1"
Endif

If FwFldGet("RBW_MOTIVO") == "1"   //Validacoes para Motivo == 1	
	//Validacoes do campo RBW_MATSUB 
	If !NaoVazio() .And. cCampo == 'RBW_CPFSUB'  
		lRetorno := .F.
    EndIf			
Else
	If !Empty(FwFldGet(cCampo))
		Help( ,, 'Help',, OemtoAnsi(STR0009), 1, 0 ) //"Campo deve ser vazio para essa motivo"				
		lRetorno := .F.
	EndIf 
EndIf 

If lRetorno
	For nC := 1 To LEN(aCPFs)
		If !Empty(aCPFs[nC]) .And. cCMP1 <> AllTrim(STR(nC)) .And. !Empty(AllTrim(FwFldGet(cCampo)))
			If ( aScan( aCPFs , { |x| x == AllTrim(FwFldGet(cCampo)) } ) <> VAL(cCMP1) )
				lRetorno := .F.
				Help( ,, 'Help',, OemtoAnsi(STR0023), 1, 0 ) //"O CPF do substituído não pode se repetir."	
			Endif			
		Endif
	Next nC
Endif

RestArea(aSaveArea)

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ f927Comm      ³ Autor ³ Glaucia Messina  ³ Data ³05/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para integracao TAF evento S-2200                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA927                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function f927Comm(oModel)
Local lRet	   		:= .T.
Local cStatus  		:= " "
Local cStat1   		:= " "
Local cCPFCun  		:= " "
Local cCPF	   		:= ""
Local cCateg   		:= ""
Local cMsgLog       := ""
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|309" //Trabalhador com vinculo
Local cFilEnv		:= ""
Local nCont			:= 1
Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local aErros		:= {}

Local aInfoC		:= {}
Local cChaveMid		:= ""
Local cNrInsc		:= ""
Local cTpInsc		:= ""
Local lAdmPubl		:= .F.
Local lEnvia		:= .T.
Local lS2206		:= .T.

cCateg	:= SRA->RA_CATEFD
cCPF    := AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)

If cVerTrab >= "9.0.00" 
	lS2206 	:= .F. 
	If oModel:GetOperation() == 4
		lEnvia	:= fCpoAlt(oModel, SRA->RA_FILIAL + SRA->RA_MAT, @lS2206)
	EndIf
EndIf

If (lIntTAF .Or. lMiddleware) .AND. !(EMPTY(cCPF)) .AND. !(EMPTY(cCateg)) .And. FUNNAME() <> "GPEM035" .And. (cVerTrab < "9.0.00" .Or. (cVerTrab >= "9.0.00" .And. lEnvia))
	If Type('cVerTrab') == "U"
		If ( ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2100", .F.,,,@cVerTrab),cVerTrab:= "2.2")
	Endif 

	If !lMiddleware
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
	EndIf

	RegToMemory("SRA")
	If Empty(SRA->RA_CODUNIC)
		MsgAlert(OemToAnsi(STR0017)) //Funcionario sem codigo unico gerado. Acessar o Cad. Funcionario ou Realizar Carga Inicial
		lRet := .F.
	Else	
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf
		If cCateg $ cTrabVincu 
			cCPFCun		:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
			If !lMiddleware
				cStatus 	:= TAFGetStat( "S-2200", cCPFCun, cEmpAnt, cFilEnv )
				cStat1 		:= TAFGetStat( "S-2100", cCPFCun, cEmpAnt, cFilEnv )
			Else
				cStat1	:= "-1"
				cStatus := "-1"
				fPosFil( cEmpAnt, SRA->RA_FILIAL )
				aInfoC   := fXMLInfos()
				If LEN(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
				cStatus 	:= "-1"			
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatus )
			EndIf
			If cVerTrab < "2.3" .And. cStat1 <> "-1" // O REGISTRO 2100 foi emitido, sendo assim vamos gerar um retificador   
				lRet:= fIntAdmiss("SRA",,,"S2100",,,,oModel,,aErros,cVerTrab)
			Else
				If cStatus  $ " |-1|0|1|3"   //Não existe no TAF ou existe e ainda não foi transmitido
					lRet:= fIntAdmiss("SRA", Nil, oModel:GetOperation(), Nil, Nil, Nil, Nil, oModel, Nil, @aErros, cVerTrab)
				ElseIf cStatus == "4"
					If !lS2206
						lRet := fIntAdmiss("SRA", Nil, oModel:GetOperation(), "S2200", Nil, Nil, Nil, oModel, Nil, @aErros, cVerTrab, )
					Else
   				   		lRet := fInt2206("SRA", , 4,"S2206",,,,,,oModel, cVerTrab) 
					EndIf
				Else //cStatus == "2"
					If !lMiddleware
						oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0018)) //Em transito
					Else
						oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0026)) //"Registro de admissão do funcionário em trânsito ao RET. A alteração não será efetivada."
					EndIf
					lRet := .F.
				Endif
			Endif	
		Endif
	Endif	
	
	If lRet .And. FindFunction("fEFDMsg")
		fEFDMsg()
	ElseIf Len(aErros) > 0
	   For nCont:= 1 to len(aErros)
	       If aErros[nCont] == "TPJORN"
	          cMsgLog+= CRLF + STR0025 //"O Tipo de Jornada não foi localizado, favor verificar o cadastro do funcionário para que o mesmo seja integrado corretamente." 
	       Else
	          cMsgLog+= CRLF + aErros[nCont]
	       EndIf
	   Next 
	EndIf
EndIf

If !Empty(cMsglog)
    oModel:SetErrorMessage("",,oModel:GetId(),"","",cMsgLog)
EndIf
If lRet
	FWFormCommit(oModel)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp927Tom³ Autor ³ Claudinei Soares      ³ Data ³ 23/08/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o CPNJ informado no campo RBW_INSCT pertence a Raiz³±± 
±±³          ³ do CNPJ do Campo RBW_INSC.                                   ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp927Tom()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTpInsc   = Tipo de Inscrição, campo RBW_TPINSC              ³±±
±±³          ³ cInsc     = Número da Inscrição, campo RBW_INSC              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fGp927Tom()

Local cTp 		:= ""
Local cIns 	:= ""
Local cTpT		:= ""
Local cInsT	:= ""
Local cCNPJ	:= ""
Local cCNPJT	:= ""
Local lRet 	:= .T.
Local oMdl   	:= FwModelActive()

oMdl:Activate()

cTp 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_TPINSC')
cIns 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_INSC')
cTpT 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_TPINST')
cInsT 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_INSCT')

If cTp == cTpT .And. cTp == "1"
	cCNPJ	:= Left(cIns,8)
	cCNPJT	:= Left(cInsT,8)
	
	If Alltrim(cIns) == Alltrim(cInsT)
		lRet := .F.
		Help( ,, 'Help',, OemtoAnsi(STR0019)+ CRLF + OemtoAnsi(STR0020), 1, 0 ) //"Ao Preencher o campo Insc.Tomador ele deve pertencer a raiz do CNPJ do campo Nr.Inscrição" // "Caso os CNPJ's sejam iguais não é necessário preencher o campo Insc. Tomador."
	ElseIf cCNPJ == cCNPJT
		lRet := .T.
	Else
		lRet := .F.
		Help( ,, 'Help',, OemtoAnsi(STR0019)+ CRLF + OemtoAnsi(STR0020), 1, 0 ) //"Ao Preencher o campo Insc.Tomador ele deve pertencer a raiz do CNPJ do campo Nr.Inscrição" // "Caso os CNPJ's sejam iguais não é necessário preencher o campo Insc. Tomador."
	Endif
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GpeSocWhen ³ Autor ³ Claudinei Soares      ³ Data ³ 11/09/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificacao de When para Cadastro de Funcionarios Temporarios³±± 
±±³          ³                                                              ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GpeSocWhen()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GpeSocWhen()

Local aSaveArea:= GetArea()
Local lRetorno := .T.

RestArea(aSaveArea)

Return lRetorno 


/*/{Protheus.doc} fCpoAlt
Verifica se os campos de envio do evento para a versão S-1.0 foram alterados 
@since	28/01/2020
@autor	lidio.oliveira
@version 12
/*/
Static Function fCpoAlt(oModel, cChave, lS2206)

Local oMdlRBW	:= oModel:GetModel("RBWDETAIL")
Local lAlterou  := .F.	
Local aArea		:= GetArea()
Local aAreaRBW	:= RBW->(GetArea())
Local bCond     := {|x|(  RBW->RBW_LOCT <> oMdlRBW:GetValue("RBW_LOCT") )}//Campos que se alterados geram o evento S2206
Local bCondRet	:= {|x|(  RBW->RBW_MOTIVO <> oMdlRBW:GetValue("RBW_MOTIVO") ) .Or.; //Campos que se alterados geram o evento S2200
( RBW->RBW_CPFSUB <> oMdlRBW:GetValue("RBW_CPFSUB") )  .Or.;
( RBW->RBW_JUST <> oMdlRBW:GetValue("RBW_JUST") ) .Or.;
( RBW->RBW_TPINST <> oMdlRBW:GetValue("RBW_TPINST") ) .Or.;
( RBW->RBW_INSCT <> oMdlRBW:GetValue("RBW_INSCT ") ) .Or.;
( RBW->RBW_CPF2 <> oMdlRBW:GetValue("RBW_CPF2") ) .Or.;
( RBW->RBW_CPF3 <> oMdlRBW:GetValue("RBW_CPF3") ) .Or.;
( RBW->RBW_CPF4 <> oMdlRBW:GetValue("RBW_CPF4") ) .Or.;
( RBW->RBW_CPF5 <> oMdlRBW:GetValue("RBW_CPF5") ) .Or.;
( RBW->RBW_CPF6 <> oMdlRBW:GetValue("RBW_CPF6") ) .Or.;
( RBW->RBW_CPF7 <> oMdlRBW:GetValue("RBW_CPF7") ) .Or.;
( RBW->RBW_CPF8 <> oMdlRBW:GetValue("RBW_CPF8") ) .Or.;
( RBW->RBW_CPF9 <> oMdlRBW:GetValue("RBW_CPF9") )}

Default cChave	:= ""
Default lS2206	:= .F.

	If !Empty(cChave )
		dbSelectArea( "RBW" )
		//Pesquisa pelo registro, se não encontrou se trata de uma inclusão
		If dbSeek(cChave ,.T.) 
			//Sempre que o registro estiver deletado haverá integração
			If oMdlRBW:IsDeleted()
				lAlterou := .T.
			//Executa o bloco de código com as validações de retificação
			ElseIf Eval( bCondRet )
				lAlterou	:= .T.
			//Executa o bloco de código com as validações das alterações
			Elseif Eval( bCond )
				lAlterou	:= .T.
				lS2206		:= .T.
			Endif
		Else
			lAlterou := .T.
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaRBW)

Return lAlterou
