#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA923.CH'

Static cEFDAviso

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ GPEA923  ³ Autor ³ Emerson Campos                    ³ Data ³ 21/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Estabilidades" (RFX)                       					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA923()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±³Luis Artuso ³09/10/2015³00000030680/2015³Retirada validacao que impedia cadastrar es-³±±
±±³            ³          ³                ³tabilidade com data superior a database do  ³±±
±±³            ³          ³                ³sistema.  									³±±
±±³Raquel Hager³24/08/2016³TVTOQD          ³Remoção do uso do parâmetro MV_INTTAF para  ³±±
±±³            ³          ³                ³release 12.1.7.							    ³±±
±±³Cecília Carv³08/01/2018³DRHESOCP-2682   ³Ajuste para geração de contrato intermitente³±±
±±³            ³          ³                ³ - evento S-2200.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEA923 ()
Local oMBrowse
Local cFiltraRh
Local aArea		:= GetArea()
Local lIntTaf 	:= .F. // Futuramente tratará o parâmetro MV_RHTAF
   
cEFDAviso  		:= If( cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas

//Validacao se aplicou update 1.1 eSocial		
If lIntTaf .AND. !fGP17VrTaf() //Validacao se TAF esta instalado
	MsgAlert(OemToAnsi(STR0052)+" "+ OemToAnsi(STR0049)+" "+ OemToAnsi(STR0050),OemToAnsi(STR0047)) //##"Ambiente TAF desatualizado."##"Assim esta rotina não poderá ser utilizada."##"Entre em contato com o Administrador do Sistema."##"Atencao"			
Else
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0014)) //Estabilidades

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltraRh := CHKRH("GPEA923","SRA","1")
	oMBrowse:SetFilterDefault( cFiltraRh )
	oMBrowse:SetLocate()
	GpLegMVC(@oMBrowse)
	
	oMBrowse:ExecuteFilter(.T.)
	
	oMBrowse:Activate()
EndIf
	
RestArea(aArea)

Return

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

ADD OPTION aRotina Title STR0009  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0010  Action 'VIEWDEF.GPEA923'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0011  Action 'VIEWDEF.GPEA923'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title STR0012  Action 'VIEWDEF.GPEA923'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Emerson Campos        ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para o Cadastro de  ³±±
±±³          ³Fatos Relevantes do Funcionario (RFX)                         ³±±
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
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|RA_ADMISSA|"}
Local oStruSRA 		:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRFX 		:= FWFormStruct(1, 'RFX', /*bAvalCampo*/,/*lViewUsado*/)
Local oMdlRFX
Local lIntTaf 		:= .F. // Futuramente tratará o parâmetro MV_RHTAF
Local aColsAux		:= {}                        
Local bLinePre		:= {|oMdl| Gp923PreLine(oMdl)}
Local bPosVal		:= {|oMdl| Gp923PosCpo(oMdl)}
Local bPosValid 	:= {|oMdl| Gp923PosVal(oMdl, aColsAux, lIntTaf)}

oMdlRFX := MPFormModel():New('GPEA923', /*bPreValid*/ , bPosValid, {|oModel|Gpa923Commit(oModel)}/*bCommit*/, /*bCancel*/)

oMdlRFX:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

oMdlRFX:AddGrid( 'RFXDETAIL', 'SRAMASTER', oStruRFX, bLinePre, /*bLinePos/*, /*bPreVal*/, bPosVal, /*BLoad*/ ) 


oMdlRFX:SetRelation('RFXDETAIL', {{'RFX_FILIAL', 'xFilial("RFX")'}, {'RFX_MAT', 'RA_MAT'}}, RFX->(IndexKey(1)))

oMdlRFX:GetModel('RFXDETAIL'):SetUniqueLine({'RFX_MAT', 'RFX_DATAI', 'RFX_TPESTB'})

//Permite grid sem dados
oMdlRFX:GetModel('RFXDETAIL'):SetOptional(.T.)

oMdlRFX:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlRFX:GetModel('SRAMASTER'):SetOnlyQuery(.T.)

// Adiciona a descricao do Modelo de Dados
oMdlRFX:SetDescription(OemToAnsi(STR0006))  // "Cadastro de Estabilidades"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlRFX:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0013)) // "Funcionários"
oMdlRFX:GetModel('RFXDETAIL'):SetDescription(OemToAnsi(STR0014)) // "Estabilidades"

oMdlRFX:SetVldActivate({|oMdl| Gp923ValAnt(oMdlRFX, aColsAux, lIntTaf)})

Return oMdlRFX

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Emerson Campos        ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizador de dados do Cadastro de Fatos Relevantes do     ³±±
±±³          ³ Funcionario (RFX)                                            ³±±
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
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|RA_ADMISSA|"}
Local oModel   	:= FWLoadModel('GPEA923')
Local oStruSRA 		:= FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRFX 		:= FWFormStruct(2, 'RFX')

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')
oStruSRA:SetNoFolder()

oView:AddGrid('VIEW_RFX', oStruRFX, 'RFXDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 16)
oView:CreateHorizontalBox('INFERIOR', 84)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RFX', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0013)) // "Funcionário"
oView:EnableTitleView('VIEW_RFX', OemToAnsi(STR0014)) // "Estabilidades"

oView:SetCloseOnOk({ || .T. })		//Desabilita botão "Salvar e Criar Novo"

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp923PosCpo ³ Autor ³ Emerson Campos        ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel validação campos do grid.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp923PosCpo( oMdlRFX )                                       ³±±
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
Static Function Gp923PosCpo( oMdlRFX )

Local oModel	:= oMdlRFX:GetModel('RFXDETAIL')
Local dDtIniEST	:= FwfldGet("RFX_DATAI")
Local dDtFimEST	:= FwfldGet("RFX_DATAF")        
Local lRet		:= .T. 

If ReadVar() == "M->RFX_MAT" 
	lRet := .F. 
ElseIf ReadVar() == "M->RFX_DATAI" 
	If !Empty(dDtIniEST) 
		If dDtIniEST < SRA->RA_ADMISSA
			lRet:= .F.
			Help( ,, 'Help',, OemtoAnsi(STR0015)+" "+dtoc(SRA->RA_ADMISSA)+".", 1, 0 ) //"Data do início da estabilidade deve ser igual ou superior a data de admissão. Funcionário admitido em:"
		ElseIf !Empty(SRA->RA_DEMISSA) .AND. dDtIniEST >= SRA->RA_DEMISSA
			lRet:= .F.
			Help( ,, 'Help',, OemtoAnsi(STR0016)+" "+dtoc(SRA->RA_DEMISSA)+".", 1, 0 )	//"Data do início da estabilidade deve ser inferior a data de demissão. Funcionário demitido em:"
		ElseIf !Empty(dDtFimEST) .AND. dDtIniEST > dDtFimEST
			lRet:= .F.
			Help( ,, 'Help',, OemtoAnsi(STR0017), 1, 0 )			//"Data do início da estabilidade deve ser inferior ou igual a data do término da estabilidade."
		EndIf
	EndIf
ElseIf ReadVar() == "M->RFX_DATAF" 
	If !Empty(dDtFimEST)
		lRet := ChkValDt(dDtFimEST,dDtIniEST,"<=",STR0019,.T.)//"Data do fim da estabilidade deve ser superior a data de início da estabilidade."

		If lRet .AND. !Empty(SRA->RA_DEMISSA)
			lRet := ChkValDt(dDtFimEST,SRA->RA_DEMISSA,">",STR0020+" "+dtoc(SRA->RA_DEMISSA),.T.)//"Data do fim da estabilidade deve ser inferior a data de demissão. Funcionário demitido em:"				
		EndIf
	
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp923ValAnt ³ Autor ³ Alessandro Santos     ³ Data ³ 10/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Armazena valores do grid na abertura                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp923ValAnt(oMdlRFX, aColsAux)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRFX = Objeto do modelo                                   ³±±
±±³          ³ aColsAux = Array para adicionar grid inicial                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. 		                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA923                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Gp923ValAnt(oMdlRFX, aColsAux, lIntTaf)

Local aArea			:= GetArea()
Local aAreaRFX		:= RFX->(GetArea())
Local oModel		:= oMdlRFX:GetModel('RFXDETAIL')
Local lRet			:= .T.
Local cTrabVincu 	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|304|306" //Trabalhador com vinculo

RFX->(dbSetOrder(1))

//Validacao para chamada pelo menu
If IsInCallStack("GPEA923")
	If SRA->RA_SITFOLH == "D" .And. oMdlRFX:GetOperation() <> 1  
		Help( , , 'HELP', , OemToAnsi(STR0056)+" "+OemToAnsi(STR0049), 1, 0 ) //##"Funcionário está demitido"##"Assim esta rotina não poderá ser utilizada."
		lRet := .F.
	EndIf
	
	If lRet .AND. lIntTaf //Vrifica se continua e se integra com TAF
		If "ERR" $ FGetIdInt("cpfTrab", "matricula", SRA->RA_CIC, SRA->(RA_FILIAL+RA_MAT)) .Or. Empty(FGetIdInt("cpfTrab", "matricula", SRA->RA_CIC, SRA->(RA_FILIAL+RA_MAT))) //Verifica se funcionario foi integrado com TAF					
			Help(,, "Help",, OemtoAnsi(STR0053)+" "+OemToAnsi(STR0049), 1, 0) //##"Funcionário não integrado ao TAF."##"Assim esta rotina não poderá ser utilizada."
			lRet := .F.	
		ElseIf !SRA->RA_CATEFD $ cTrabVincu //Validacao vinculo do funcionario  
			Help( , , 'HELP', , OemToAnsi(STR0057), 1, 0 ) //##"Permitido apenas funcionários com vínculo conforme eSocial"		
			lRet := .F.	
		EndIf
	
		If lRet
			//Limpa array
			aColsAux := {}
			
			//Busca todas informacoes no grid e adiciona no array auxiliar
			//Nao necessario verificar se linha esta deletada nesse momento
			If oModel:GetOperation() == 4 //Opcao de alteracao
				If RFX->(MsSeek(xFilial("RFX") + SRA->RA_MAT))
					While RFX->(!EOF())	 .And. RFX->(RFX_FILIAL + RFX_MAT) == SRA->(RA_FILIAL + RA_MAT)						
						If !Empty(RFX->RFX_DATAF) //Verifica se Data de cancelamento contem informacoes 
							//Alimenta array auxiliar
							aAdd(aColsAux, {RFX->RFX_FILIAL,; 
											RFX->RFX_MAT,;
											RFX->RFX_DATAF,; 
											RFX->RFX_TPESTB})	
						EndIf
						
						RFX->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf
EndIf	
		
RestArea(aAreaRFX)
RestArea(aArea)
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp923PosVal ³ Autor ³ Emerson Campos        ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do Cadastro de Estabilidades                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp923PosVal( oMdlRFX )                                       ³±±
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
Function Gp923PosVal( oMdlRFX, aColsAux, lIntTaf )

Local oModel	:= oMdlRFX:GetModel('RFXDETAIL')
Local lRetorno	:= .T.

//Integracao com o TAF - S2340 e S2345
If lIntTaf
	IntEstab(oModel:GetOperation(), oModel, aColsAux)
EndIf

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RFXDATAIVL    ³ Autor ³ Emerson Campos   ³ Data ³11/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para validação da data inicial da estabilidade      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function RFXDATAIVL()
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RFXDATAFVL    ³ Autor ³ Emerson Campos   ³ Data ³11/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para validação da data final da estabilidade        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function RFXDATAFVL()
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fMotEstab     ³ Autor ³ Emerson Campos   ³ Data ³10/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para disponibilizar uma lista de opcoes dos motivos ³±±
±±³          ³ de estabilidade                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function fMotEstab()
Local cTitulo  	:= "Motivo"
Local MvPar    	:=""
Local MvParDef 	:=""
Local lRet     	:= .T.
Local l1Elem   	:= .T.
Local oWnd

Private aOcor:={}
cEFDAviso  		:= If( cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas

If Alltrim(ReadVar() )= "M->MOTEST"

	cAlias 	:= Alias() 					// Salva Alias Anterior
	MvPar	:= &(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
	MvRet	:= Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
    
	aOcor := {;
			OemToAnsi(STR0029),;		//"01=Acidente de Trabalho;"
			OemToAnsi(STR0030),;		//"02=Mandato Sindical;"
			OemToAnsi(STR0031),;		//"03=Mandato Eleitoral;"
			OemToAnsi(STR0032),;		//"04=Gravidez;"
			OemToAnsi(STR0033),;		//"05=Prestação de Serviço Militar"
			OemToAnsi(STR0034),;		//"06=Convenção Coletiva de Trabalho"
			OemToAnsi(STR0035),;		//"07=Candidato da CIPA;"
			OemToAnsi(STR0036),;   		//"08=Eleito Titular CIPA;" 
			OemToAnsi(STR0037),;   		//"09=Eleito Suplente CIPA;"
			OemToAnsi(STR0038),;   		//"10=Membro do Conselho Nacional da Previdência Social (CNPS);"
			OemToAnsi(STR0039),;   		//"11=Membro de Comissão de Conciliação Prévia;"
			OemToAnsi(STR0040),;   		//"12=Empregados eleitos diretores de sociedades cooperativas;"
			OemToAnsi(STR0041),;   		//"13=Membros do Conselho Curador do FGTS;"
			OemToAnsi(STR0042) ;   		//"99=Outros;"
	          }
	
	MvParDef:= "0102030405060708091011121399"
	   
	If f_Opcoes(@MvPar,cTitulo,aOcor,MvParDef,,,l1Elem,2)  	//Chama funcao f_Opcoes
		&MvRet := SubStr(MvPar,1,2) 						//Devolve Resultado
	EndIF
	dbSelectArea(cAlias) 									//Retorna Alias
	lRet := .F.
	
	If Pertence("01#02#03#04#05#06#07#08#09#10#11#12#13#99")
		lRet := .T.
	Else
		lRet := .F.
	EndIf

ElseIf !empty(MvPar)
	lRet := .F.
EndIf

If oWnd != Nil
	GetdRefresh()
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fGp923TpEst   ³ Autor ³ Alessandro Santos³ Data ³03/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para validação do tipo de estabilidade - RFX_TPESTB ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA923                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/


Function fGp923TpEst()

Local lRet := .T.

//Nao permite gravidez para masculino
If SRA->RA_SEXO == "M" .And. M->RFX_TPESTB == "S02"
	lRet := .F.
	Help(,, "Help",, OemtoAnsi(STR0051), 1, 0) //##"Tipo de estabilidade não permitido para funcionário"
ElseIf SRA->RA_SEXO == "F" .And. M->RFX_TPESTB == "S08" //Nao permite servico militar para feminino
	lRet := .F.
	Help(,, "Help",, OemtoAnsi(STR0051), 1, 0) //"Tipo de estabilidade não permitido para funcionário"
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp923PreLine³ Autor ³ Alessandro Santos     ³ Data ³ 09/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel validacao dos campos Data Inicio e Tipo de³±±
±±³          ³ Estabilidade antes da alteracao.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp923PreLine(oMdlRFX  )                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRFX = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA923                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Gp923PreLine(oMdlRFX)

Local aArea		:= GetArea()
Local aAreaRFX := RFX->(GetArea())
Local lRet 		:= .T.

RFX->(dbSetOrder(1))
SX3->(dbSetOrder(2))

//Valida se Estabilidade ja existe na base da dados para gravacao de data inicial e tipo estabilidade
If ReadVar() $ "M->RFX_DATAI|M->RFX_TPESTB" .AND.;
	RFX->(MsSeek(FwfldGet("RFX_FILIAL") + FwfldGet("RFX_MAT") + DToS(FwfldGet("RFX_DATAI")) + FwfldGet("RFX_TPESTB")))
	
	//Posiciona no campo atual
	SX3->(MsSeek(Subs(ReadVar(), 4, Len(ReadVar()))))
				
	Aviso(OemToAnsi(STR0047), OemtoAnsi(STR0054)+" "+AllTrim(SX3->X3_TITULO)+" "+OemtoAnsi(STR0055), {"OK"}) //##"Atenção"##"O campo"##"não pode ser alterado."
	lRet := .F.										
EndIf	

RestArea(aAreaRFX)
RestArea(aArea)

Return lRet

/*/{Protheus.doc}Gpa923Commit
Função responsável pelo commit do modelo
@author Leandro Drumond
@since 03/02/2017
@version P11
/*/
Static Function Gpa923Commit(oModel)
Local aArea			:= GetArea()
Local nOperacao  	:= oModel:GetOperation()
Local dDataFim		:= CtoD("")
Local oGrid			:= oModel:GetModel( "RFXDETAIL" )
Local nTam			:= oGrid:Length()
Local nX			:= 0 

If nOperacao == MODEL_OPERATION_DELETE
	RecLock("SRA", .F.)
	SRA->RA_DTVTEST :=  CtoD("")
	MsUnLock()
Else
	For nX := 1 To nTam
		oGrid:GoLine( nX )
		If !oGrid:IsDeleted() .and. oGrid:GetValue( "RFX_DATAF" ) > dDataFim
			dDataFim := oGrid:GetValue( "RFX_DATAF" )
		EndIf
	Next nX
	RecLock("SRA",.F.)
	SRA->RA_DTVTEST := dDataFim
	MsUnLock()
EndIf

FWFormCommit( oModel ) //--Grava model

RestArea(aArea)

Return .T.
