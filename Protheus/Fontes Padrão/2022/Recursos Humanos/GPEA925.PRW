#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA925.CH'

Static cTpAviso
Static lMiddleware
//Integração com o TAF 
//A integração com o TAF é desabilitada quando middleware ativo, desta forma não realiza validações do eSocial e tantativa de integração
Static lIntTaf

/*/ 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ GPEA925  ³ Autor ³ Emerson Campos                    ³ Data ³ 21/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Aviso Prévio (RFX)                       					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA925()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Emerson Camp³02/09/2013³00000012013/2013³Ajuste na apresentação da tela para acompa- ³±±
±±³            ³          ³          THFBYA³nhar o padrão do sistema                    ³±±
±±³Emerson Camp³11/11/2013³00000029415/2013³Ajuste na apresentação da data projetada do ³±±
±±³            ³          ³          TIA004³aviso para não inserir um dia a mais confor-³±±
±±³            ³          ³                ³me entendimento do documento do eSocial.    ³±±
±±³            ³          ³                ³Validar para que sempre os campos de data ou³±±
±±³            ³          ³                ³tipo de cancelamento estivam preenchidos.   ³±±
±±³            ³          ³                ³                                            ³±±
±±³Cícero Alves³31/03/2015³			 TRYDQE³Alterações nas funções de validação dos 	³±±
±±³            ³          ³          	   ³campos RFY_TPAVIS e RFY_TPRESC				³±±
±±³M. Silveira ³29/01/2016³			 TUHJNF³Corrigida a validacao da data do Av. Previo ³±±
±±³            ³          ³          	   ³na funcao RFYDTASVPVLD para nao gerar erro. ³±±
±±³Claudinei S.³18/02/2016³          TUCD45³Incluido novo controle para o Aviso Previo  ³±±
±±³            ³          ³                ³Misto (Trabalhado e Indenizado)             ³±±
±±³Claudinei S.³29/02/2016³          TUCD45³Incluida HabilitCpo() para tratar o when dos³±±
±±³            ³          ³                ³campos RFY_DIASAV e RFY_DAVCUM'             ³±±
±±³Claudinei S.³16/06/2016³          TURBCB³Setado como .T. a variavel lProj, caso não  ³±±
±±³            ³          ³                ³possua o campo RCE_PRJAVT.                  ³±±
±±ºClaudinei S.³18/03/2016³          TUSEC0³Ajustada a validação do tipo de rescisão    ³±±
±±º            ³          ³                ³para não permitir que seja informado o tipo ³±±
±±º            ³          ³                ³do aviso 4 e rescisão com aviso descontado. ³±±
±±ºRenan Borges³05/04/2016³          TUP601³Ajuste para abater o valor de % de salário  ³±±
±±º            ³          ³                ³educação corretamente do valor de terceiros.³±±
±±º            ³          ³                ³Ajuste para validar o cadastro de tipo de   ³±±
±±º            ³          ³                ³aviso previo corretamente de acordo com os  ³±±
±±º            ³          ³                ³periodos ativos. Ajuste para utilizar o mne-³±±
±±º            ³          ³                ³monico P_CHKDTHOM  ao realizar o calculo de ³±±
±±º            ³          ³                ³rescisão.                                   ³±±
±±ºRaquel Hager³20/04/2016³          TV0922³Ajuste para geracao da Dt Fim Av Previo     ³±±
±±º            ³          ³                ³correta a contar a partir do dia seguinte.  ³±±
±±³Raquel Hager³14/06/2016³          TV0922³Ajuste para abater 1 dia para geração do dia³±±
±±³            ³          ³                ³de aviso corretamente.Criação da função     ³±±
±±³            ³          ³                ³fCpoDAv para verificar existencia do campo  ³±±
±±³            ³          ³                ³RG_DAVIND no dicionário de dados.           ³±±
±±³Allyson M   ³18/07/2016³     	 TVNTNE³Ajuste p/ não checar validação de data de   ³±±
±±³            ³          ³            	   ³demissão ao preencher os dias de aviso devi-³±±
±±³            ³          ³           	   ³do ao conceito de poder alterar os dias de  ³±±
±±³            ³          ³           	   ³aviso.    						 			³±±
±±³Eduardo V   ³19/07/2017³    DRHESOCP-281³Replica da versão 11 e ajustes para esocial ³±±
±±³            ³          ³            	   ³Versão atualizada.							³±±
±±³Marcia Moura |02/06/2017|DRHESOCP-316    | Pacote para Atendimento, subindo correcao ³±±
±±³Marcia Moura³12/06/2017³DRHESOCP-399    ³Alteracoes para que o evento s-2250 seja    º±±
±±³            ³          ³                ³gerado mesmo quando o evento de admissao    º±±
±±³            ³          ³                ³ainda nao tenha sido integrado com  o TAF   º±±
±±³Marcos Cout.³25/08/2017³DRHESOCP-791    ³Realizando ajustes para que o Aviso Previo  ³±±
±±³            ³          ³                ³seja gerado corretamente para funcionarios  ³±±
±±³            ³          ³                ³de outras filiais que não sejam a matriz    ³±±
±±³Marcos Cout.³04/09/2017³DRHESOCP-950    ³Realizando a tratativa da mensagem de erro  ³±±
±±³            ³          ³                ³do FwModelPos. A mensagem de erro de retorno³±±
±±³            ³          ³                ³do TAF é impressa dentro da tela de erro.   ³±±
±±³Cecília Carv³08/01/2018³DRHESOCP-2682   ³Ajuste para geração de contrato intermitente³±±
±±³            ³          ³                ³ - evento S-2200.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEA925 (xAutoCab,xAutoItens,nOpcAuto)
Local cFiltraRh
Local oBrwSRA
Local xRetFilRh
Local cFil
Local cMat
Local oModelAuto
Local lRet			:= .T.

Private lGp925Auto  :=(xAutoCab<>NIl)
Private aAutoCab	:= {}
Private aAutoItens  := {}
Private lCpoDAV		:= fCpoDAv() // Verifica se campo virtual RG_DAVIND existe no dicionário de dados
Private aColsAux	:= {}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando Filtro de BROWSE                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//--Seta e Carrega os Mnemonicos.
SetMnemonicos(NIL,NIL,.T.)

If lGp925Auto .or. nOpcAuto <> Nil
	If lGp925Auto
		dbSelectArea("SRA")
		aAutoCab	:= xAutoCab
		aAutoItens 	:= xAutoItens
		
		If (nT := aScan(aAutoCab,{|x| UPPER(Alltrim(x[1]))=='RA_FILIAL'})) > 0
			cFil := aAutoCab[nT,2]
		Else
			cFil := xFilial("SRA")
		EndIf
		If (nT := aScan(aAutoCab,{|x| UPPER(Alltrim(x[1]))=='RA_MAT'})) > 0
			cMat := aAutoCab[nT,2]
		EndIf
		
		dbSelectArea('SRA')
		dbSetOrder(1)
		If !dbSeek(cFil+cMat)
			AutoGRLog(STR0007+" "+ Alias()+" "+Dtoc(MsDate())+' '+Time() ) // "Tabela "
			AutoGrLog("RA_FILIAL: "+cFil)
			AutoGrLog("RA_MAT: "+cMat)
			AutoGRLog(STR0008) // "Pesquisa não encontrada com os dados acima"   
			AutoGRLog(Replicate("-",80))
			lRet := .F.
		EndIf
	
		If lRet
			aRotina := MenuDef()
			
			//Executa rotina automatica SEM Interface
			lRet := FWMVCRotAuto(ModelDef(),"SRA",nOpcAuto,{{"SRAMASTER",aAutoCab},{"RFYDETAIL",aAutoItens}},.F.,.T.)
		EndIf
	Else
		FWExecView(STR0006,'GPEA925', nOpcAuto, , { || .T. } ) //"Cadastro de Aviso Prévio"
	EndIf
Else
	oBrwSRA := FWmBrowse():New()		
	oBrwSRA:SetAlias( 'SRA' )
	oBrwSRA:SetDescription(STR0006)	//"Cadastro de Aviso Prévio"
	
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH==' '"	, "GREEN"	, OemToAnsi(STR0001)  )//"Situação Normal"  
	oBrwSRA:AddLegend( "SRA->RA_RESCRAI$'30/31'", "PINK"  	, OemToAnsi(STR0002)  )//"Transferido" 
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='D'"	, "RED"		, OemToAnsi(STR0003)  )//"Demitido"
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='A'"	, "YELLOW"  , OemToAnsi(STR0004)  )//"Afastado"
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='F'"	, "BLUE"	, OemToAnsi(STR0005)  )//"Férias"     
						
	//Inicializa o filtro utilizando a funcao FilBrowse
	xRetFilRh := CHKRH(FunName(),"SRA","1")
	If ValType(xRetFilRh) == "L"
		cFiltraRh := if(xRetFilRh,".T.",".F.")
	Else
		cFiltraRh := xRetFilRh
	EndIf
	//Filtro padrao do Browse conforme tabela SRA (Funcionários)
	oBrwSRA:SetFilterDefault(cFiltraRh)
	oBrwSRA:SetMenuDef("GPEA925")
	
	oBrwSRA:DisableDetails()	
	oBrwSRA:Activate()
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ Emerson Campos        ³ Data ³ 21/06/13 ³±±
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

ADD OPTION aRotina Title STR0009  Action 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0010  Action 'VIEWDEF.GPEA925'  OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0011  Action 'VIEWDEF.GPEA925' 	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title STR0012  Action 'VIEWDEF.GPEA925'  OPERATION 5 ACCESS 0 //"Excluir"
Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Emerson Campos      ³ Data ³ 21/06/13   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para o Cadastro de  ³±±
±±³          ³Fatos Relevantes do Funcionario (RFY)                         ³±±
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
//Define os campos do SRA que serão apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA 		:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRFY 		:= FWFormStruct(1, 'RFY', /*bAvalCampo*/,/*lViewUsado*/)
Local oMdlRFY
Local lResc			:= .F.

// Blocos de codigo do modelo
Local bLinePos		:= {|oModel| fGp925LinOk()}
Local bPosValid
Local aColsAux		:= {} 

DEFAULT lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
DEFAULT lIntTaf 	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 .And. !lMiddleware)

bPosValid 			:= {|| fGp925TdOk(aColsAux, lIntTaf) }

// Cria o objeto do Modelo de Dados
oMdlRFY := MPFormModel():New('GPEA925', /*bPreValid*/ , bPosValid, /*bCommit*/, /*bCancel*/)

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oMdlRFY:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oMdlRFY:AddGrid( 'RFYDETAIL', 'SRAMASTER', oStruRFY, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	
// Faz relaciomaneto entre os compomentes do model
oMdlRFY:SetRelation('RFYDETAIL', {{'RFY_FILIAL', 'xFilial("RFY")'}, {'RFY_MAT', 'RA_MAT'}}, RFY->(IndexKey(1)))

//Define Chave Única
oMdlRFY:GetModel('RFYDETAIL'):SetUniqueLine({'RFY_MAT', 'RFY_DTASVP'})

//Permite grid sem dados
oMdlRFY:GetModel('RFYDETAIL'):SetOptional(.T.)

oMdlRFY:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlRFY:GetModel('SRAMASTER'):SetOnlyQuery(.T.)


// Adiciona a descricao do Modelo de Dados
oMdlRFY:SetDescription(OemToAnsi(STR0006))  // "Cadastro de Aviso Prévio"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlRFY:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0013)) // "Funcionários"
oMdlRFY:GetModel('RFYDETAIL'):SetDescription(OemToAnsi(STR0014)) // "Aviso Prévio"

// O campo Data do aviso só poderá ser informado após informar o tipo de rescisão
oMdlRFY:AddRules( "RFYDETAIL", "RFY_DTASVP", "RFYDETAIL", "RFY_TPRESC", 1 )

oStruRFY:SetProperty( 'RFY_DIASAV', MODEL_FIELD_WHEN, {|oMdl2| HabilitCpo('RFYDETAIL') } )

If RFY->(ColumnPos( "RFY_DAVCUM")) > 0
	oStruRFY:SetProperty( 'RFY_DAVCUM', MODEL_FIELD_WHEN, {|oMdl2| HabilitCpo('RFYDETAIL') } )
EndIf

//--Limpa cTpAviso na montagem do model
//oMdlRFY:SetVldActivate( { |oModel| cTpAviso := "", cFilAnt := SRA->RA_FILIAL, .T. } )
oMdlRFY:SetVldActivate( { |oModel| Gp925VldFun(oMdlRFY, aColsAux, lIntTaf),cTpAviso := "", cFilAnt := SRA->RA_FILIAL,.T.})
Return oMdlRFY	
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Emerson Campos        ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizador de dados do Cadastro de Fatos Relevantes do     ³±±
±±³          ³ Funcionario (RFY)                                            ³±±
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
//Define os campos do SRA que serão apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA925')
// Cria a estrutura a ser usada na View
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRFY := FWFormStruct(2, 'RFY')

DEFAULT lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
DEFAULT lIntTaf 	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 .And. !lMiddleware)

// Cria o objeto de View
oView := FWFormView():New()
 
// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')

oStruSRA:SetNoFolder()

// Altera a ordem do campo Tipo de rescisão
oStruRFY:SetProperty( 'RFY_TPRESC' , MVC_VIEW_ORDEM, '03')

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RFY', oStruRFY, 'RFYDETAIL')

oStruRFY:RemoveField("RFY_MAT")
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 12)
oView:CreateHorizontalBox('INFERIOR', 88)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RFY', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0013)) // "Funcionário"
oView:EnableTitleView('VIEW_RFY', OemToAnsi(STR0014)) // "Aviso Prévio"

oView:addUserButton(OemToAnsi(STR0073) ,"MAGIC_BMP", {||fGp925TdOk(aColsAux, lIntTaf) }, ,, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW } ) //"Reenviar ao TAF"

oView:SetCloseOnOk( { |oView| .T. } )

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fPosValGp925³ Autor ³ Emerson Campos        ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao da linha do Cadastro de Aviso prévio           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fPosValGp925( oMdlRFY )                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRFY = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fGp925LinOk(lTudoOk)
Local aPerAtual		:= {}
Local dDataProj		:= {}
Local dRch_DtIni	:= {}
Local dRch_DtFim	:= {}
Local lRet   		:= .T.
Local oModel    	:= FWModelActive()
Local oMdlRFY 		:= oModel:GetModel( 'RFYDETAIL' )
Local nLinAtual		:= oMdlRFY:GetLine( )
Local nI			:= 0
Local nCont			:= 0
Local cTrabTaf		:= AllTrim(SRA->RA_CIC) + SRA->RA_CODUNIC
Local cChaveAvs		:= cTrabTaf + ";" + Dtos(oMdlRFY:GetValue("RFY_DTASVP"))
Local cVersTrab     := ""
Local cVersGPE      := ""

DEFAULT lTudoOk		:= .F.

DEFAULT lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
DEFAULT lIntTaf 	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 .And. !lMiddleware)

If fGetPerAtual( @aPerAtual, xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, fGetCalcRot('4') )
	dRch_DtIni	:= aPerAtual[1,6]
	dRch_DtFim	:= aPerAtual[1,7]
Else
	Help( ,, OemToAnsi(STR0036),, OemToAnsi(STR0062), 1, 0 ) //Não existe período de cálculo aberto para a competência.
	Return (.F.)
EndIf

//Para inserir uma nova linha e necessario que as demais tenha os campos de cancelamento preenchidos
For nI := 1 To oMdlRFY:Length()
	oMdlRFY:GoLine( nI )
	if oModel:GetOperation() <> 5
		If !oMdlRFY:IsDeleted()
			If 	Empty(oMdlRFY:GetValue( 'RFY_TPCAP' ) ).or.;
				Empty(oMdlRFY:GetValue( 'RFY_DTCAP' ) )
				nCont++
			Else
				Loop
			EndIf
			
			//Nao permite rescisao com data anterior ao periodo atual
			If !Empty(dRch_DtIni) .And. !Empty(dRch_DtFim)
				dDataProj := oMdlRFY:GetValue( 'RFY_DTPJAV') 
				If ( dDataProj < dRch_DtIni )
					Help( ,, OemToAnsi(STR0036),, OemToAnsi(STR0063), 1, 0 ) //Data de Demissao menor que a Data Inicial do Periodo Atual
					lRet := .F.
					Exit
				Endif
				If ( dDataProj > dRch_DtFim )
					fRetPerComp(SubStr(Dtos(dDataProj),5,2), SubStr(Dtos(dDataProj),1,4),, SRA->RA_PROCES,fGetCalcRot("4"),@aPerAberto )
					If Empty(aPerAberto)
						Help( ,, OemToAnsi(STR0036),, OemToAnsi(STR0062), 1, 0 ) //"Não existe período de cálculo aberto para a competência"
						lRet := .F.
						Exit
					EndIf
				EndIf  
			EndIf
		
			If !Empty(oMdlRFY:GetValue( 'RFY_TPCAP' )) .and. Empty(oMdlRFY:GetValue( 'RFY_DTCAP' ) ) 
				lRet	:= .F. 
				Help( , , 'HELP', , OemToAnsi( STR0034 ), 1, 0 ) //"Se o campo 'Tp.Canc.Av.P' estiver preenchido o campo 'Dt.Cancel.AP' torna-se obrigatório!"
				Exit
			EndIf
				
			If Empty(oMdlRFY:GetValue( 'RFY_TPCAP' )) .and. !Empty(oMdlRFY:GetValue( 'RFY_DTCAP' ) )
				lRet	:= .F. 
				Help( , , 'HELP', , OemToAnsi( STR0035 ), 1, 0 ) //"Se o campo 'Dt.Cancel.AP' estiver preenchido o campo 'Tp.Canc.Av.P' torna-se obrigatório!"
				Exit
			EndIf
		EndIf
	Endif
Next nI

oMdlRFY:GoLine( nLinAtual )
If !(lTudoOk .OR. oMdlRFY:IsDeleted())
	If lRet .and. nCont > 1 
		lRet	:= .F.
		Help( , , 'HELP', , OemToAnsi( STR0032 ), 1, 0 )//"Já existe um aviso prévio cadastrado para este funcionário, um novo aviso prévio só poderá ser inserido quando os demais estiverem com os campos de cancelamento preenchidos."	 	
	EndIf

	If (ExistFunc('fVersEsoc'), fVersEsoc("S2299", .F., , , @cVersTrab, @cVersGPE),)
	
	If lRet .And. ((lIntTaf) .And. (cVersGPE < "9.0"))
		If oMdlRFY:IsFieldUpdated("RFY_DTCAP") .And. TAFGetStat( "S-2250", cChaveAvs ) ==  '-1'
			lRet := .F.
			Help( , , 'help','Dt.Cancel.' , OemToAnsi( STR0059 ), 1, 0 ) //"Não é possível realizar o cancelamento do registro pois o evento ainda não foi enviado ao RET..."
		EndIf
		If !(oMdlRFY:IsFieldUpdated("RFY_DTCAP")) .And. dDataBase > (oMdlRFY:GetValue('RFY_DTASVP') + 10)
			//lRet := .F.
			If !IsBlind()
				MsgInfo ( OemToAnsi( STR0056 ), 'Entrega A.P.' )
			EndIf
			//Help( NIL, NIL, "Help", 'Entrega A.P.' , OemToAnsi( STR0056 ), 1, 0, NIL, NIL, NIL, NIL, NIL, {} ) //"Atenção: O envio do registro de Aviso Prévio deve ser em até '10 dias' da sua comunicação!"
		EndIf
		
		If (oMdlRFY:IsFieldUpdated("RFY_DTCAP")) .And.;
			(oMdlRFY:IsFieldUpdated("RFY_DTASVP") .Or. oMdlRFY:IsFieldUpdated("RFY_DTPJAV") .Or. oMdlRFY:IsFieldUpdated("RFY_TPAVIS") .Or. oMdlRFY:IsFieldUpdated("RFY_OBSAV"))
			lRet := .F.
			Help( , , 'help','Canc. A.P.' , OemToAnsi( STR0060), 1, 0 ) //"Não é possível realizar o cancelamento concomitantemente a uma alteração. Realize primeiro a alteração para depois cancelar o registro."
		EndIf
	EndIf
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fGp925TdOk  ³ Autor ³ Emerson Campos        ³ Data ³ 29/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do modelo relativo ao Cadastro de Aviso prévio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fPosValGp925( oMdlRFY )                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRFY = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fGp925TdOk(aColsAux, lIntTaf)

Local lRet		:= .F.
Local oModel	:= FWModelActive()
Local lResc		:= .F.
Local oMdlRFY	:= oModel:GetModel("RFYDETAIL")

Local aErros := {}
Local aTitle := {}
Local cTrabTaf := AllTrim(SRA->RA_CIC) + ";" + SRA->RA_CODUNIC
Local cChaveAvs := cTrabTaf + ";" + Dtos(oMdlRFY:GetValue("RFY_DTASVP"))
Local cCPF1:= ""

Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local aIncRes		:= {}
Local cFilEnv 		:= ""
Local cTpRes		:= ""
Local cEFDAviso		:= If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")) //Integracao com TAF)
Local cMSG			:= ""
Local cVersTrab     := ""
Local cVersGPE      := ""

Private lGp40	:= .F.
Private aTpAlt := {.F.,.F.,.F.}
Private cStatus := ""
Private cStat1 := ""		

cCPF1 := AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
If fGp925LinOk(.T.)
	If !oModel:GetModel("RFYDETAIL"):IsInserted()
		lResc := fResc()                                                 
	Endif

	If !lResc
		lRet := .T.
	Endif
Endif

If Funname() == "GPEM040"
	lAvPrevRfy := .T.
Endif

If (ExistFunc('fVersEsoc'), fVersEsoc("S2299", .F., , , @cVersTrab, @cVersGPE),)

//S2250
If lRet .And. ((lIntTaf) .And. (cVersGPE < "9.0"))

	//VALIDA O PREENCHIMENTO DO MOTIVO DA RESCISÃO NA TABELA S043

	//--------------------------------------------------------------
	//| Importante: MV_EFDAVIS -> cEFDAviso							|
	//| "0": Somente informa a obrigatoriedade, mas permite passar	|
	//| "1": informa e bloqueia se encontrar inconsistências		|
	//| "2": não informa e nem bloqueia								|
	//--------------------------------------------------------------
	If cEFDAviso <> "2"
		cTpRes := oMdlRFY:GetValue("RFY_TPRESC")
		fIncRes(SRA->RA_FILIAL,cTpRes,@aIncRes)

		If Len(aIncRes) > 0 .And. Empty(aIncRes[16])
			cMsg:= OemtoAnsi(STR0067) + CRLF + CRLF	// "O motivo da rescisão não foi informado e é obrigatório para o eSocial "
			If cEFDAviso == "0"
				cMsg+= OemtoAnsi(STR0068) + CRLF	// "conforme conteúdo do parâmetro MV_EFDAVIS, "
				cMsg+= OemtoAnsi(STR0069) + CRLF	// "não será impeditivo para a gravação do aviso prévio."
				If !IsBlind()
					MsgAlert(cMsg, OemToAnsi(STR0066) )	// "Campo não preenchido"
				Endif
			Else
				cMsg+= OemtoAnsi(STR0070) + CRLF + CRLF		// "favor preencher o campo Mot.eSocial da tabela S043 - Tipos de Rescisão. "
				cMsg+= OemtoAnsi(STR0068) + CRLF				// "conforme conteúdo do parâmetro MV_EFDAVIS, "
				cMsg+= OemtoAnsi(STR0071) + CRLF				// "será necessário o preenchimento do campo para efetivar a gravação do aviso prévio."
				Help( , , OemtoAnsi(STR0066), , cMsg, 1, 0)	// "Campo não preenchido"	
				lRet :=  .F.
			EndIf
		Endif
	Endif

	If lRet
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf
	
		//Verifica se o registro do funcionario existe e esta integrado com TAF com sucesso
		cStatus := TAFGetStat( "S-2200", cCPF1, cEmpAnt, cFilEnv)
		cStat1 := TAFGetStat( "S-2100", cCPF1, cEmpAnt, cFilEnv)
		
		//Baseado no Status do trabalhador, decide o caminho a seguir.
		If(cStat1 == "2" .OR. cStatus == "2")
			MsgAlert(OemToAnsi(STR0065)) //"eSocial: Registro de admissão do funcionário em trânsito TAF x RET. A alteração não será efetivada."
			lRet := .F.
		Else
			fStatusTAF(@aTpAlt,cStatus,cStat1)
			If aTpAlt[3] // existe o 2200 2100 na base do TAF
				If oModel:GetOperation() <> 5
					fAvsPrvEso(oModel:GetOperation(),@aErros,oMdlRFY)
					If ( Len(aErros) > 0 ) //Visualizar o Log?
						lRet := .F.
						oModel:SetErrorMessage("",,oModel:GetId(),"","Atenção",aErros[1])
					EndIf
				Else
					fAvsPrvEso(oModel:GetOperation(),@aErros,oMdlRFY)
					If (Len(aErros) > 0)
						lRet := .F.
						oModel:SetErrorMessage("",,oModel:GetId(),"","Atenção",aErros[1])
					EndIf
				endif
			Else
				Help( , , 'HELP',"Integ. TAF" , OemToAnsi( STR0058 ), 1, 0 ) //Não será possível enviar o Aviso Prévio para o TAF pois o registro de Admissão ou Carga Inicial deste funcionário não foi enviado ao RET...
				lRet := .F.
			EndIf
		EndIf
	Endif	
EndIf
Return (lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RFYDTASVPVLD  ³ Autor ³ Emerson Campos   ³ Data ³11/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para validação da data aviso prévio			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function RFYDTASVPVLD()
Local lRet 			:= .T.
Local lOk			:= .T.
Local lAltera		:= .F.
Local oModel 		:= FWModelActive()
Local dDtInAvPr 
Local dDatadem  
Local nAnosCasa		:= 0
Local nAuxAnosCasa	:= 0
Local nDiasAv		:= 0
Local nDiasCum		:= 0
Local nDiasInd		:= 0
Local cTpAviso		:= ""
Local cTipoAviso	:= ""
Local cTpRes		:= ""
Local lProj			:= .F.
Local lDataAviso	:= Valtype(&(ReadVar())) == "D"

Private lProjav		:= .F.

If !oModel:GetModel("RFYDETAIL"):IsInserted()
	lAltera := .T.
Endif

If RCE->(ColumnPos( "RCE_PRJAVT")) > 0
	If (fDesc( "RCE", SRA->RA_SINDICA, "RCE_PRJAVT" )) == "1"
		lProj := .T.
	Endif
Else
	lProj := .F.
Endif

If !Empty(oModel:GetValue( 'RFYDETAIL', 'RFY_TPAVIS' ))
	cTpAviso := oModel:GetValue( 'RFYDETAIL', 'RFY_TPAVIS' )
	If !Empty(oModel:GetValue( 'RFYDETAIL', 'RFY_TPRESC' ))
		cTpRes := oModel:GetValue( 'RFYDETAIL', 'RFY_TPRESC' )
		fIncRes(SRA->RA_FILIAL,cTpRes,@aIncRes)
		lProJav := aIncRes[17] == "S"
		cTipoAviso := aIncRes[2]		
	Endif
	If oModel:GetValue( 'RFYDETAIL', 'RFY_TPAVIS' ) <> "3"
		// Se calcula o numero de dias do Aviso Proporcional para Pedido Demissao 
		If oModel:GetValue( 'RFYDETAIL', 'RFY_TPAVIS' ) $ '3*4' .AND. Type("P_AVPROPDE" ) <> "U" 
			If P_AVPROPDE == "N" 
				lOk	:= .F.
			EndIf
		EndIf
			
		dDtInAvPr		:= oModel:GetValue( 'RFYDETAIL', 'RFY_DTASVP' ) 
		If (fDesc( "RCE", SRA->RA_SINDICA, "RCE_DIASAV" )) == 0
			dDatadem		:= DaySum( dDtInAvPr , 30 )		
		Else
			dDatadem		:= DaySum( dDtInAvPr , (fDesc( "RCE", SRA->RA_SINDICA, "RCE_DIASAV")) )
		Endif
		
		nAnosCasa 		:= fAnosCasa( dDataDem , SRA->RA_ADMISSA )
		nAuxAnosCasa	:= 0
		nDiasAv	:= fComplAvP(dDtInAvPr,nAnosCasa,cTipoAviso,,cTpAviso, .T.) 

		lRet := ChkValDt(dDtInAvPr,SRA->RA_ADMISSA,"<",STR0020+" "+dtoc(SRA->RA_ADMISSA),.T.)//"Data do aviso prévio deve ser  superior a data de admissão. Funcionário admitido em:"

		If RFY->(ColumnPos( "RFY_DAVCUM")) > 0
			nDiasCum := oModel:GetValue( 'RFYDETAIL', 'RFY_DAVCUM') 
		Endif

		If nDiasCum > nDiasAv
			lRet := .F.
		Endif
		
		If lRet 
			If RFY->(ColumnPos( "RFY_DAVCUM")) > 0
				nDiasCum := oModel:GetValue ( 'RFYDETAIL', 'RFY_DAVCUM' )
			Endif
			If nAnosCasa == 0 .And. nAuxAnosCasa == 0
				If nDiasCum == 0 .Or. lAltera
					nDiasCum := (fDesc( "RCE", SRA->RA_SINDICA, "RCE_DIASAV" ))
					If nDiasCum == 0
						nDiasCum := 30
					Endif
				Endif
			Endif
			//Logica para gerar automaticamente os numeros de dias de aviso previo e data projetada 
			While nAnosCasa <> nAuxAnosCasa  
				If nDiasAv >= 30 .AND. nDiasAv <= 90
					If nDiasCum == 0
						nDiasCum := (fDesc( "RCE", SRA->RA_SINDICA, "RCE_DIASAV" ))
						If nDiasCum == 0
							nDiasCum := 30
						Endif
					Endif
					nAuxAnosCasa	:= nAnosCasa
					dDatadem		:= DaySum( dDtInAvPr , nDiasAv )
					If lProj
						dDatadem		:= DaySum( dDtInAvPr , nDiasCum )
					Endif
					
					If oModel:GetValue( 'RFYDETAIL', 'RFY_DIASAV') == 0 .or. lAltera// primeira vez
						nDiasAv := fComplAvP(dDtInAvPr, nAnosCasa, cTipoAviso, , cTpAviso, .T.) //fComplAvP atende ao mnemonico "nAnoAviPro"
						// Se for alteração, conserva já inserido no campo.
						If lAltera
							nDiasAv := oModel:GetValue( 'RFYDETAIL', 'RFY_DIASAV')
						EndIf
					Else
						nDiasAv := oModel:GetValue( 'RFYDETAIL', 'RFY_DIASAV')
					Endif
					nDiasInd := ( nDiasAv - nDiasCum )
				EndIf
				If nDiasAv > 90
					Exit
				EndIf 
			EndDo		
			//oModel:SetValue( 'RFYDETAIL', 'RFY_DIASAV', nDiasAv   )     
			oModel:LoadValue( 'RFYDETAIL', 'RFY_DIASAV', nDiasAv   )
			If RFY->(ColumnPos( "RFY_DAVCUM")) > 0 .And. lCpoDAV
				oModel:LoadValue( 'RFYDETAIL', 'RFY_DAVIND', nDiasInd  )
				oModel:LoadValue( 'RFYDETAIL', 'RFY_DAVCUM', nDiasCum  )
			Endif
			If nDiasCum > 0 
				oModel:LoadValue( 'RFYDETAIL', 'RFY_DTPJAV', DaySum( dDtInAvPr , nDiasCum )  )
			Else
				oModel:LoadValue( 'RFYDETAIL', 'RFY_DTPJAV', DaySub(DaySum( dDtInAvPr , nDiasAv ),1)  )
			Endif
			
			dDataProj := oModel:GetValue( 'RFYDETAIL', 'RFY_DTPJAV') 
		EndIf
	Else
		dDtInAvPr := oModel:GetValue( 'RFYDETAIL', 'RFY_DTASVP' )
		oModel:LoadValue( 'RFYDETAIL', 'RFY_DTPJAV', dDtInAvPr )
		oModel:LoadValue( 'RFYDETAIL', 'RFY_DTPJAV', M->RFY_DTASVP )
	Endif
Else
	Help( , , 'HELP', , OemToAnsi(STR0023), 1, 0 )//"Selecione o tipo de Aviso Prévio (Tp.Av.Prev.)!"
	lRet := .F.
EndIf
Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RFYDIASAVVLD  ³ Autor ³ Emerson Campos   ³ Data ³11/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para validação dos dias de aviso prévio		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function RFYDIASAVVLD()
Local lRet 			:= .T.
Local oModel 		:= FWModelActive()
Local dDataDesl		:= CtoD ("//")
Local nDias 		:= 0

If !Empty(oModel:GetValue( 'RFYDETAIL', 'RFY_DTASVP' ))
	If oModel:GetValue( 'RFYDETAIL', 'RFY_TPAVIS' ) <> "3"
		oModel:SetValue( 'RFYDETAIL', 'RFY_DTPJAV', DaySub(DaySum( DaySum(oModel:GetValue( 'RFYDETAIL', 'RFY_DTASVP' ), 1) , M->RFY_DIASAV ), 1) )   
	Else
		dDataDesl:= oModel:GetValue( 'RFYDETAIL', 'RFY_DTASVP' )
		oModel:SetValue( 'RFYDETAIL', 'RFY_DTPJAV', dDataDesl )
	EndIf                                                              
	If RFY->(ColumnPos( "RFY_DAVCUM")) > 0
		nDias := (oModel:GetValue( 'RFYDETAIL', 'RFY_DAVCUM' ))
		//Tratativa para que, se alterar os dias de aviso, os dias de aviso cumprido e indenizado sigam a alteração e não fiquem negativos.
		nDias := If (nDias > M->RFY_DIASAV, M->RFY_DIASAV, nDias)
		oModel:LoadValue('RFYDETAIL', 'RFY_DAVCUM', nDias) 
	Else
		nDias := 0
	Endif
	If lCpoDAV
		oModel:LoadValue( 'RFYDETAIL', 'RFY_DAVIND', 0 )
		oModel:SetValue( 'RFYDETAIL', 'RFY_DAVIND', (M->RFY_DIASAV - nDias)  )
	Endif
EndIf                           

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RFYDTPJAVVLD  ³ Autor ³ Emerson Campos   ³ Data ³11/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para validação da data de projeção do aviso prévio  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function RFYDTPJAVVLD()
Local lRet		:= .T.
Local oModel 	:= FWModelActive()
lRet :=  ChkValDt(M->RFY_DTPJAV,oModel:GetValue( 'RFYDETAIL', 'RFY_DTASVP') ,"<=",STR0024,.T.) .AND. fChkDtDem(oModel:GetValue( 'RFYDETAIL', 'RFY_DTPJAV'),.T.) //"A data projetada do aviso deve ser superior a data do aviso prévio."        

Return lRet  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fTpAvPrevBox()³ Autor ³ Emerson Campos   ³ Data ³10/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para disponibilizar uma lista de opcoes dos motivos ³±±
±±³          ³ de aviso prévio                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function fTpAvPrevBox()
Local cTitulo           := OemToAnsi("Tp.Av.Prev.") // ""Tp.Av.Prev.""
Local MvPar             := &(ReadVar())
Local MvParDef          := "" 
Local MvStrRet          := ""
Local lRet              := .T. 
Local l1Elem            := .F.  
Local nGrupo            := 0
Local aArea             := GetArea()
Local aRet				:= array(2)
Local cVersEnvio		:= ""
Local cVersGPE			:= ""

Private aOcor := {}

fVersEsoc( 'S2299', .F., , @aRet, @cVersEnvio,@cVersGPE )

VAR_IXB := MvPar


aOcor := {;			
			OemToAnsi(STR0016),;		//"1=Aviso prévio trabalhado dado pelo empregador ao empregado, que optou pela redução de duas horas diárias [capit do art. 488 da CLT]"
			OemToAnsi(STR0017),;		//"2=Aviso prévio trabalhado dado pelo empregador ao empregado, que optou pela redução de dias corridos [parágrafo único do art. 488 da CLT]"
			OemToAnsi(STR0019),;		//"4=Aviso prévio dado pelo empregado (pedido de demissão), não dispensado de seu cumprimento, sob pena de desconto, pelo empregador, dos salários correspondentes ao prazo respectivo (§2º do art. 487 da CLT)"			
			OemToAnsi(STR0064) ;		//"5=Aviso prévio trabalhado dado pelo empregador rural ao empregado, com redução de um dia por semana (art. 15 da Lei 5889/73)."
	          }

MvParDef := "1245"

If cVersEnvio >= "2.4.02"
    aAdd(aOcor, OemToAnsi(STR0072))     //"6 - Aviso prévio trabalhado decorrente de acordo entre empregado e empregador (art. 484-A, "caput", da CLT)."
    MvParDef := "12456"
EndIf

If f_Opcoes(@MvPar, cTitulo, aOcor, MvParDef,,, l1Elem)
      For nGrupo := 1 To Len(MvPar)
            If (SubStr(MvPar, nGrupo, 1) # "*")
                  MvStrRet += SubStr(mvpar, nGrupo, 1)
            Else
                  MvStrRet += Space(1)
            Endif
      Next nGrupo
      VAR_IXB := AllTrim(MvStrRet)
EndIf

RestArea(aArea)
Return(lRet) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RFYTPAVVLD()  ³ Autor ³ Emerson Campos   ³ Data ³10/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para validar o tipo de aviso prévio em um intervalo ³±±
±±³          ³ entre 1 e 6                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function RFYTPAVVLD()
Local lRet 		:= .T.
Local aRet      := array(2)
Local cVersEnvio:= ""
Local cVersGPE  := ""

Local oModel 	:= FWModelActive()
fVersEsoc( 'S2299', .F., , @aRet, @cVersEnvio,@cVersGPE )

If Empty(oModel:GetValue( 'RFYDETAIL', 'RFY_TPCAP' ))

	If !Empty(oModel:GetValue( 'RFYDETAIL', 'RFY_DTASVP' ))
		oModel:LoadValue( 'RFYDETAIL', 'RFY_DTASVP', cTod("//") )
		oModel:LoadValue( 'RFYDETAIL', 'RFY_DIASAV', 0 )
		oModel:LoadValue( 'RFYDETAIL', 'RFY_DTPJAV', cTod("//") )
		If RFY->(ColumnPos( "RFY_DAVCUM")) > 0 .And. lCpoDAV
			oModel:LoadValue( 'RFYDETAIL', 'RFY_DAVCUM', 0 )
			oModel:LoadValue( 'RFYDETAIL', 'RFY_DAVIND', 0 )
		Endif
	EndIf

	If !M->RFY_TPAVIS $ "1*2*3*4*5" + IIF(cVersEnvio >= "2.4.02", "*6", "")
		Help( , , 'HELP', , OemToAnsi(STR0025), 1, 0 )//"O tipo de aviso prévio selecionado é invalido!"
		lRet := .F.
	EndIf
Else
	Help( , , 'HELP', , OemToAnsi(STR0033), 1, 0 )//"O Campo Tipo de Aviso Prévio não pode ser alterado!"
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fTpAvPrevBox()³ Autor ³ Emerson Campos   ³ Data ³26/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para disponibilizar uma lista de opcoes dos motivos ³±±
±±³          ³ de aviso prévio                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function fTpCAPBox()
Local cTitulo           := OemToAnsi("Tp.Canc.Av.P") // "Tp.Canc.Av.P"
Local MvPar             := &(ReadVar())
Local MvParDef          := "" 
Local MvStrRet          := ""
Local lRet              := .T. 
Local l1Elem            := .F.  
Local nGrupo            := 0
Local aArea             := GetArea()

Private aOcor := {}

VAR_IXB := MvPar

aOcor := {;			
			OemToAnsi(STR0027),;		//"1=Reconsideração prevista no artigo 489 da CLT;"
			OemToAnsi(STR0028),;		//"2-Determinação Judicial;" 
			OemToAnsi(STR0029),;		//"3=Cumprimento de norma legal;" 
			OemToAnsi(STR0030) ;		//"9=Outros;"
	          }

MvParDef := "1239"

If f_Opcoes(@MvPar,cTitulo,aOcor,MvParDef,,,l1Elem)
      For nGrupo := 1 To Len(MvPar)
            If (SubStr(MvPar, nGrupo, 1) # "*")
                  MvStrRet += SubStr(mvpar, nGrupo, 1)
            Else
                  MvStrRet += Space(1)
            Endif
      Next nGrupo
      VAR_IXB := AllTrim(MvStrRet)
EndIf

RestArea(aArea)
Return(lRet) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fRfyTpCAPVld()³ Autor ³ Emerson Campos   ³ Data ³26/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para validar o tipo de cancelamento do aviso prévio ³±±
±±³          ³ em um intervalo entre 1 e 3 + 9                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function fRfyTpCAPVld()
Local lRet 		:= .T. 

If !M->RFY_TPCAP $ "1*2*3*9"
	Help( , , 'HELP', , OemToAnsi(STR0026), 1, 0 )//"O tipo de cancelamento do aviso prévio selecionado é inválido!"
	lRet := .F.
EndIf

Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fRfyDtCAP     ³ Autor ³ Emerson Campos   ³ Data ³26/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função p validação da data do cancelamento do aviso prévio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function fRfyDtCAP()
Local lRet		:= .T.
Local oModel 	:= FWModelActive()
lRet :=  Empty(M->RFY_DTCAP) .OR. ChkValDt(M->RFY_DTCAP,oModel:GetValue( 'RFYDETAIL', 'RFY_DTASVP') ,"<",STR0031,.T.)//"A data do cancelamento do aviso prévio deve ser igual ou superior a data do aviso prévio."    

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Gp925VldRes   ³ Autor ³ Leandro Drumond  ³ Data ³05/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função p validação do tipo de rescisao.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function Gp925VldRes()

Local cTpRes	:= &(ReadVar())
Local cTab		:= "S043"
Local cRfyTpAv  := ""
Local lRet		:= .F.
Local oModel 	:= FWModelActive()
Local aRet      := array(2)
Local cVersEnvio:= ""
Local cVersGPE  := ""

fVersEsoc( 'S2299', .F., , @aRet, @cVersEnvio,@cVersGPE )

cRfyTpAv := oModel:GetValue( 'RFYDETAIL', 'RFY_TPAVIS' )

If Empty(cTpRes)
	Return .T.
EndIf

dbSelectArea( "RCC" )
dbSetOrder(1)
dbSeek(xFilial("RCC",SRA->RA_FILIAL) + cTab)
While !Eof() .and. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC",SRA->RA_FILIAL)+cTab
	If RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC",SRA->RA_FILIAL)+cTab .and. Alltrim(Substr(RCC->RCC_CONTEU,1,2)) == AllTrim(cTpRes)
		cTpAviso := AllTrim(Substr(RCC->RCC_CONTEU,34,1))
		lRet := .T.
		Exit
	EndIf
	dBSkip()
EndDo

If !lRet
	Help(" ",1, "NOTAB")
	
//	Será incluido novamente quando e-Social estiver completo.
Else
	If !Empty(cRfyTpAv)
		If (cRfyTpAv $ "1*2*4*5" .And. cTpAviso == "T") .Or.;
			(cRfyTpAv == "3" .And. cTpAviso == "N") .Or.;
			(If(cVersEnvio >= "2.4.02", "6", "") == cRfyTpAv .And. cTpAviso == "B")  
			 lRet := .T.
		Else
			lRet := .F.
			Help( , , STR0036, , OemToAnsi(STR0037), 1, 0 )//"Tipo de Aviso Prévio informado difere do tipo de aviso prévio do tipo de rescisão"
		EndIf
	EndIf
	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fResc         ºAutor ³Marcia Moura     º Data ³  28/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para verificar se o funcionario ja possui rescisao   º±±
±±           ³calculada ao tentar alterar o cadastro de aviso previo.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fResc()
Local lRet 		:= .F.
Local aArea     := GetArea()

	dbSelectArea("SRG")
	IF SRG->( MsSeek( ( SRA->RA_FILIAL + SRA->RA_MAT ) ) )
		Help( , , 'HELP', , OemToAnsi(STR0050), 1, 0 )//"Já existe rescisão vinculada a este funcionário. Antes de alterar será necessário excluir a rescisão"
		lRet := .T.
	Endif
	RestArea( aArea )
 
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HabilitCpo    ºAutor ³Leandro Drumond  º Data ³  28/08/13   º±±
±±º          ³     Reutilizado por:³Claudinei Soares º Data ³  15/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³WHEN dos campos de dias da RFY			                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function HabilitCpo(cExtru)
Local lRet 		:= .F.
Local cMyCod  	:= ""
Local oMdl     	:= FWModelActive()
Local oMyMdl01  := oMdl:GetModel(cExtru)

cMyCod := oMyMdl01:GetValue('RFY_TPAVIS')

lRet:= If(cMyCod <> "3", .T., .F.)
 
Return lRet      

/*{Protheus.doc} fCpoDAv()

Verifica se o campo RFY_DAVIND (contexto virtual) existe no dicionario de dados
função ColumnPos não se aplica para campos virtuais.
 
@author Raquel Hager
@since 14/06/2016
@version P12 R7
*/
Function fCpoDAv()
Local aArea	:= GetArea()
Local lRet		:= .F.

	dbSelectArea("SX3")
	dbSetOrder(2) // X3_CAMPO
	If SX3->(dbSeek("RFY_DAVIND"))
		lRet	:= .T.
	EndIf

RestArea(aArea)

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Gp925VldFun   ³ Autor ³ Alessandro Santos³ Data ³11/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao p validacao inicial do Aviso Previo.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA925                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
					  

Function Gp925VldFun(oMdlRFY, aColsAux, lIntTaf)
Local aArea			:= GetArea()
Local aAreaRFY		:= RFY->(GetArea())
Local oModel		:= oMdlRFY:GetModel('RFYDETAIL')
Local lRet 			:= .T.
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|304|306" //Trabalhador com vinculo
Local cVersTrab     := ""
Local cVersGPE      := ""

default  aColsAux:= {}
RFY->(dbSetOrder(1))

If SRA->RA_SITFOLH == "D" .And. oMdlRFY:GetOperation() <> 1  
	Help( , , 'HELP', , OemToAnsi(STR0047)+" "+OemToAnsi(STR0040), 1, 0 ) //##"Funcionário está demitido"##"Assim esta rotina não poderá ser utilizada."
	lRet := .F.
EndIf

If (ExistFunc('fVersEsoc'), fVersEsoc("S2299", .F., , , @cVersTrab, @cVersGPE),)

If lRet .AND. ((lIntTaf) .And. (cVersGPE < "9.0")) //Valida se continua e se integra com TAF		
	If !SRA->RA_CATEFD $ cTrabVincu //Validacao vinculo do funcionario  
		If IsInCallStack("GPEA928")
			IF !SRA->RA_CATEFD == "901"	  
				Help( , , 'HELP', , OemToAnsi(STR0045), 1, 0 ) //##"Permitido apenas funcionários com vínculo conforme eSocial"
				lRet := .F.
			Endif
		Else
			Help( , , 'HELP', , OemToAnsi(STR0045), 1, 0 ) //##"Permitido apenas funcionários com vínculo conforme eSocial"
			lRet := .F.
		Endif	
	EndIf

	If lRet
		//Limpa array
		aColsAux := {}
		
		//Busca todas informacoes no grid e adiciona no array auxiliar
		//Nao necessario verificar se linha esta deletada nesse momento
		If oModel:GetOperation() == 4 //Opcao de alteracao
			If RFY->(MsSeek(xFilial("RFY") + SRA->RA_MAT))
				While RFY->(!EOF())	 .And. RFY->(RFY_FILIAL + RFY_MAT) == SRA->(RA_FILIAL + RA_MAT)
					If !Empty(RFY->RFY_DTCAP) //Verifica se Data de cancelamento contem informacoes 
						//Alimenta array auxiliar
						aAdd(aColsAux, {RFY->RFY_FILIAL,; 
										RFY->RFY_MAT,;
										RFY->RFY_DTCAP}) 										
					EndIf
					
					RFY->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
   
EndIf

// Filtra os registros que possuem o campo Tipo Cancelamento Aviso Previo vazio
If oMdlRFY:GetOperation() == 5
	oMdlRFY:GetModel('RFYDETAIL'):SetLoadFilter( {}, "RFY_TPCAP = '" + Space(TamSx3("RFY_TPCAP")[1]) + "'")
EndIf

RestArea(aAreaRFY)
RestArea(aArea)

Return(lRet)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³RstGpe925	  ³Autor ³Marco Nakazawa	   ³ Data ³15/01/2019³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Reinicializar as Static utilizadas no GPEA925				 ³
³          ³															 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                    	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico 													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function RstGpe925()

cTpAviso	:= NIL
lIntTaf		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )

Return( NIL )
