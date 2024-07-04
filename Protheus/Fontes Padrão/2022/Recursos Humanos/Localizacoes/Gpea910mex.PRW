#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA910.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA910   ºAutor  ³MOHANAD ODEH        º Data ³  14/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CADASTRO DE CREDITO INFONAVIT                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC/CHAMADO    ³  Motivo da Alteracao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mohanad Odeh³21/09/2011³00000024324/2011³ Inclusão de validações dos   ³±±
±±³            ³          ³TDRXMG		   ³ tipos de movimentos e cadas_   ³±±
±±³            ³          ³                ³tro de mensagens de help      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³gsantacruz  ³18/10/2011³		 ³Corr: asort (etiqueta gsa)              ³±±
±±³fmonroy     ³29/11/2011³ 	 ³Mjr: Valiaciones al campo de  RHB_TIPINF³±±
±±³R.Berti     ³13/09/2012³TFTLRJ³Creacion del fuente GPEM830MEX;		    ³±±
±±³            ³          ³      ³Se corrije funciones para estaticas.    ³±±
±±³gsantacruz  ³10/09/2012³ TFQAGX                                        ³±±
±±³lmedina     ³16/01/2012³ TGKPZB: Se modifico el asort                  ³±± 
±±³Laura Medina³19/06/2013³THDQZ0³Correcion para la eliminacion del maes- ³±±
±±³            ³          ³      ³tro de empleados del credito infonavit. ³±±
±±³Laura Medina³12/02/2014³TIGCNQ³Correcion para que actualice Empleados  ³±±
±±³            ³          ³      ³cuando se ordena por Nombre.            ³±±
±±³Raúl Ortiz M³22/04/2014³TPGGSW³Límite cuota fija: 99,9999              ³±±
±±³Laura Medina³21/10/2014³TQQPI5³Correcion para que actualice la informa-³±±
±±³            ³          ³      ³cion del credito Infonavit en Empleados ³±±
±±³Laura Medina³24/06/2015³TRRDM6³Correcion para que permita capturar un  ³±±
±±³            ³          ³      ³segundo credito que sera tratado como un³±±
±±³            ³          ³      ³reinicio con un nuevo numero de credito.³±±
±±³Alf. Medrano³22/10/2015³PCREQ-³se modifica func GPEA910GRV se Limpian  ³±±
±±³            ³          ³2095  ³variables de SRA para que se actualicen ³±±
±±³            ³          ³      ³con los nuevos valores asignados de RHB ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPEA910MEX()
Local oBrowse
Local xRetFilRh
Local cFiltraRh 	:= ""   

Private cFilInf := SRA->RA_FILIAL 
Private cMatInf := SRA->RA_MAT

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SRA')
oBrowse:SetDescription(OemToAnsi(STR0001)) // "Cadastro de Crédito Infonavit"
oBrowse:AddLegend( "SRA->RA_SITFOLH==' '", "GREEN")
oBrowse:AddLegend( "SRA->RA_SITFOLH=='D'", "RED")
oBrowse:AddLegend( "SRA->RA_SITFOLH=='A'", "YELLOW")
oBrowse:AddLegend( "SRA->RA_SITFOLH=='F'", "BLUE")

//------------------------------------------
//Busca o filtro a ser utilizado no Browse
//------------------------------------------
xRetFilRh := CHKRH(FunName(),"SRA","1")
If ValType(xRetFilRh) == "L"
	cFiltraRh := if(xRetFilRh,".T.",".F.")
Else
	cFiltraRh := xRetFilRh
EndIf

oBrowse:SetFilterDefault(cFiltraRh)
oBrowse:DisableDetails()
oBrowse:Activate() 

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ MOHANAD ODEH          ³ Data ³ 14/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
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

ADD OPTION aRotina TITLE OemToAnsi(STR0002)  		ACTION 'PesqBrw'             	OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi(STR0003)			ACTION 'VIEWDEF.GPEA910MEX' 		OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0004) 		ACTION 'VIEWDEF.GPEA910MEX'	 	OPERATION 4 ACCESS 0 // "Lançamentos"
ADD OPTION aRotina TITLE OemToAnsi(STR0005)		   	ACTION 'VIEWDEF.GPEA910MEX' 		OPERATION 8 ACCESS 0 // "Imprimir"
Return aRotina


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ MOHANAD ODEH          ³ Data ³ 14/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para o Cadastro de  ³±±
±±³          ³Credito Infonavit                                             ³±±
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
// Cria a estrutura a ser usada no Modelo de Dados
//Define os campos do SRA que serão apresentados na tela     
Local bAvalCampo          := {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA := FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRHB := FWFormStruct(1, 'RHB', /*bAvalCampo*/,/*lViewUsado*/)
Local oModel

// Blocos de codigo do modelo
//Local bPreValid	:= {|oMdl, aSavedLines ,nLines| Gp910PreVal(oMdl, aSavedLines := FWsaverows()  )}
Local bLinePos	:= {|oMdl| Gp910LinePos(oMdl)}
Local bCommit := {|oMdl| GPEA910GRV(oMdl)}
Local bPosValid := {|oMdl| Gp910PosVal(oMdl)}
Local bLinePre := {|oMdl| Gp910Lipre(oMdl)}
// REMOVE CAMPOS DA ESTRUTURA
//oStruRHB:RemoveField('RHB_MAT')


oStruRHB:SetProperty( 'RHB_TPMINF' , MODEL_FIELD_VALID,{|oMdl| GPEA9101(oMdl)}) 
oStruRHB:SetProperty( 'RHB_TIPINF' , MODEL_FIELD_WHEN,{|oMdl| !(oMdl:GetValue('RHB_TPMINF') $ '19/16') }) 
oStruRHB:SetProperty( 'RHB_NUMINF' , MODEL_FIELD_WHEN,{|oMdl| !(oMdl:GetValue('RHB_TPMINF') $ '19/16') }) 
oStruRHB:SetProperty( 'RHB_VALINF' , MODEL_FIELD_WHEN,{|oMdl| !(oMdl:GetValue('RHB_TPMINF') $ '16') }) 

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('GPEA910MEX', /*bPreValid*/ , bPosValid, bCommit, /*bCancel*/)

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'RHBDETAIL', 'SRAMASTER', oStruRHB, bLinePre, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//oModel:AddGrid( 'ZA2DETAIL', 'ZA1MASTER', oStruZA2, /*bLinePre*/,  { | oMdlG | COMP021LPOS( oMdlG ) } , /*bPreVal*/, /*bPosVal*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation('RHBDETAIL', {{'RHB_FILIAL', 'xFilial("RHB")'}, {'RHB_MAT', 'RA_MAT'}}, RHB->(IndexKey(1)))

//Define Chave Única
oModel:GetModel('RHBDETAIL'):SetUniqueLine({'RHB_MAT', 'RHB_DTMINF', 'RHB_TPMINF'})

//Permite grid sem dados
oModel:GetModel('RHBDETAIL'):SetOptional(.T.)

oModel:GetModel('SRAMASTER'):SetOnlyView(.T.)
//oModel:GetModel('SRAMASTER'):SetOnlyQuery(.T.)
//oModel:SetOnlyQuery('SRAMASTER')

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(OemToAnsi(STR0001))  // "Cadastro de Crédito Infonavit"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0006)) // "Funcionários"
oModel:GetModel('RHBDETAIL'):SetDescription(OemToAnsi(STR0007)) // "Crédito Infonavit"

// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

Return oModel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ MOHANAD ODEH          ³ Data ³ 14/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizador de dados do Cadastro de Credito Infonavit       ³±±
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
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA910MEX')
// Cria a estrutura a ser usada na View 
//Define os campos do SRA que serão apresentados na tela     
Local bAvalCampo          := {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria a estrutura a ser usada na View
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRHB := FWFormStruct(2, 'RHB')
Local oView
// Local cCampos := {}

cFilInf := SRA->RA_FILIAL 
cMatInf := SRA->RA_MAT

// Cria o objeto de View
oView := FWFormView():New()

// REMOVE CAMPOS DA ESTRUTURA
oStruRHB:RemoveField('RHB_MAT')


oStruRHB:SetProperty('RHB_DTMINF', MVC_VIEW_ORDEM,'01')
oStruRHB:SetProperty('RHB_CODRPA', MVC_VIEW_ORDEM,'02')
oStruRHB:SetProperty('RHB_TPMINF', MVC_VIEW_ORDEM,'03')
oStruRHB:SetProperty('RHB_NUMINF', MVC_VIEW_ORDEM,'04')
oStruRHB:SetProperty('RHB_TIPINF', MVC_VIEW_ORDEM,'05')
oStruRHB:SetProperty('RHB_VALINF', MVC_VIEW_ORDEM,'06')

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')

oStruSRA:SetNoFolder()

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RHB', oStruRHB, 'RHBDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 20)
oView:CreateHorizontalBox('INFERIOR', 80)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RHB', 'INFERIOR')

// Liga a identificacao do componente
// oView:EnableTitleView('VIEW_ZA2')
oView:EnableTitleView('VIEW_RHB', OemToAnsi(STR0007)) // "Crédito Infonavit"

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp910LinePos³ Autor ³ MOHANAD ODEH          ³ Data ³ 22/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos validacao de Crédito de Infonavit                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp910LinePos(oMdl)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdl = objeto do modelo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ModelDef()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp910LinePos(oModelGrid)
Local oModel    := oModelGrid:GetModel()
Local nOperation:= oModel:GetOperation()
Local aArea     := GetArea()
Local cQuery    := ''
Local cTemp		:= ''
Local lRet 		:= .T.
Local nLinha	:= 0
Local nPos:=0
Local nPosFec  :=GdFieldPos( "RHB_DTMINF" ,   oModelGrid:AHEADER)
Local nPosTip  :=GdFieldPos( "RHB_TPMINF" ,   oModelGrid:AHEADER)

If !oModelGrid:IsDeleted()
	If nOperation == 4

		nLinha		:= oModelGrid:nLine
		nLinhaAnt	:= oModelGrid:nLine - 1

		cTemp    := GetNextAlias()

		//VALIDA DATA DE MOVIMENTO
		cQuery  := ""
		cQuery  += "  SELECT * FROM " + RetSqlName('SRA') + "  "
		cQuery  += "   WHERE RA_FILIAL = '" + xFilial('SRA') + "'  "   
		//cQuery  += "     AND RA_MAT = '" + AllTrim(FwFldGet('RHB_MAT')) + "' "
		//cQuery  += "     AND RA_MAT = '" +	AllTrim(oModel:GetValue('RHBDETAIL','RHB_MAT')) + "' "		//gsa
		cQuery  += "     AND RA_MAT = '" +	AllTrim(oModelGrid:GetValue('RHB_MAT', nLinha)) + "' "		//gsa
		
	 
		cQuery  += "     AND D_E_L_E_T_ = ' ' "

		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cTemp, .F., .T.)

		If (cTemp)->RA_SITFOLH == 'D'

			If lRet .and. oModelGrid:GetValue('RHB_DTMINF', nLinha) >= STOD((cTemp)->RA_DEMISSA)
				Help(" ",1,"RHB0006") // Data de Movimento inválida ### Não é permitido movimentos para funcionários inativos, verifique a situação do funcionário
				lRet := .F.
			EndIf

		EndIf

		(cTemp)->(dbCloseArea())

        If nLinha == 1
			If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) <> '15'
				Help(" ",1,"RHB0006") // Sequência de movimentos inválida ### O primeiro Movimento deve ser do tipo Início! Verifique a sequência lógica dos movimentos
				lRet := .F.
			EndIf        
        Else
			//VALIDA FECHA fm
			If (npos:= ASCAN(oModelGrid:aDataModel, {|aVal| aVal[1, 1, nPosFec] == oModelGrid:GetValue('RHB_DTMINF', nLinha)}))>0 .and. npos<> nLinha
				If (oModelGrid:ADATAMODEL[nPos][1][1][nPosTip]=='15'.Or. oModelGrid:ADATAMODEL[nPos][1][1][nPosTip]=='16') .AND.      ;
				   (oModelGrid:ADATAMODEL[nLinha][1][1][nPosTip]=='15'.Or. oModelGrid:ADATAMODEL[nLinha][1][1][nPosTip]=='16')
					lRet := .T.
				Else
					Help( " ", 1, "Help",, "Problema: Fecha del movimiento inválida Solución: Ya existe la fecha del movimiento solo es permitida la misma fecha para movimientos de tipo Inicio y Suspensión", 1, 0 ) //gsa
						lRet := .F.
				EndIf
				
			EndIf
			//VALIDA OS TIPOS DE MOVIMENTOS
			Do Case

				Case oModelGrid:GetValue('RHB_TPMINF', nLinhaAnt) == '15' //Início

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '15'
						Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
						lRet := .F.
					EndIf

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '17'
						Help(" ",1,"RHB0009")   // Sequência de movimentos inválida ### Inclusão de Reinício só é permitida se houver uma suspensão
						lRet := .F.
					EndIf

				Case oModelGrid:GetValue('RHB_TPMINF', nLinhaAnt) == '16' //Suspensão

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) <> '17'
						Help(" ",1,"RHB00002") // Sequência de movimentos inválida ### Após um movimento de Suspensão só é permitido incluir um movimento de Reinício
						lRet := .F.
					EndIf
					
				Case oModelGrid:GetValue('RHB_TPMINF', nLinhaAnt) == '17' //Reinício

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '15'
						Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
						lRet := .F.
					EndIf

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '17'
						Help(" ",1,"RHB0008")  // Sequência de movimentos inválida ### Já existe reinício para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
						lRet := .F.
					EndIf

				Case oModelGrid:GetValue('RHB_TPMINF', nLinhaAnt) == '18' //Modificação do Tipo do Desconto

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '15'
						Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
						lRet := .F.
					EndIf

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '17'
						Help(" ",1,"RHB0009")   // Sequência de movimentos inválida ### Inclusão de Reinício só é permitida se houver uma suspensão
						lRet := .F.
					EndIf

				Case oModelGrid:GetValue('RHB_TPMINF', nLinhaAnt) == '19' //Modificação do Valor do Desconto

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '15'
						Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
						lRet := .F.
					EndIf

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '17'
						Help(" ",1,"RHB0009")   // Sequência de movimentos inválida ### Inclusão de Reinício só é permitida se houver uma suspensão
						lRet := .F.
					EndIf

				Case oModelGrid:GetValue('RHB_TPMINF', nLinhaAnt) == '20' //Modificação do Número de Crédito

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '15'
						Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
						lRet := .F.
					EndIf

					If lRet .and. oModelGrid:GetValue('RHB_TPMINF', nLinha) == '17'
						Help(" ",1,"RHB0009")   // Sequência de movimentos inválida ### Inclusão de Reinício só é permitida se houver uma suspensão
						lRet := .F.
					EndIf

			EndCase

			If lRet .and. !oModelGrid:IsDeleted(nLinha)
				If oModelGrid:GetValue('RHB_TPMINF', nLinha) == '16' .AND. (oModelGrid:GetValue('RHB_NUMINF', nLinhaAnt) <> oModelGrid:GetValue('RHB_NUMINF', nLinha);
					.OR. oModelGrid:GetValue('RHB_TIPINF', nLinha) <> oModelGrid:GetValue('RHB_TIPINF', nLinhaAnt).OR.;
							oModelGrid:GetValue('RHB_VALINF', nLinha) <> oModelGrid:GetValue('RHB_VALINF', nLinhaAnt))
					Help(" ",1,"RHB0010") // Movimento inválido ### Não é possível suspender um crédito diferente do vigente
					lRet := .F.
            	EndIf
			EndIf

			If lRet .and. !oModelGrid:IsDeleted(nLinha)
				If oModelGrid:GetValue('RHB_TPMINF', nLinha) == '17' .And. !(oModelGrid:GetValue('RHB_TPMINF', nLinhaAnt) == "16")
					Help(" ",1,"RHB0011") // Movimento inválido ### Não é possível reiniciar um crédito diferente do suspenso!
					lRet := .F.
   				Elseif oModelGrid:GetValue('RHB_NUMINF', nLinhaAnt) <> oModelGrid:GetValue('RHB_NUMINF', nLinha)  //Es un segundo credito
					 If !MSGYESNO("El movimiento será considerado como un segundo crédito, ¿Confirma que se grabara un segundo crédito?")     
					 	Help(" ",1,"RHB0011") // Movimento inválido ### Não é possível reiniciar um crédito diferente do suspenso!
					 	lRet := .F.
					 Endif
            	EndIf
			EndIf

			If lRet .and. !oModelGrid:IsDeleted(nLinha)
				If oModelGrid:GetValue('RHB_TPMINF', nLinha) == '18' .AND. (oModelGrid:GetValue('RHB_NUMINF', nLinhaAnt) <> oModelGrid:GetValue('RHB_NUMINF', nLinha);
					.OR. oModelGrid:GetValue('RHB_TIPINF', nLinha) == oModelGrid:GetValue('RHB_TIPINF', nLinhaAnt))
					Help(" ",1,"RHB0012") // Movimento inválido ### Se o tipo de movimento for igual a Modificação de Tipo de Desconto, o Tipo de Desconto deve ser modificado, mantendo os dados do Movimento vigente  
					lRet := .F.
            	EndIf
			EndIf

			If lRet .and. !oModelGrid:IsDeleted(nLinha)
				If oModelGrid:GetValue('RHB_TPMINF', nLinha) == '19' .AND. (oModelGrid:GetValue('RHB_NUMINF', nLinhaAnt) <> oModelGrid:GetValue('RHB_NUMINF', nLinha);
					.OR. oModelGrid:GetValue('RHB_VALINF', nLinha) == oModelGrid:GetValue('RHB_VALINF', nLinhaAnt))
					Help(" ",1,"RHB0013") // Movimento inválido ### Se o tipo de movimento for igual a Modificação do Valor do Desconto, o Valor do Desconto deve ser modificado, mantendo os dados do Movimento vigente
					lRet := .F.
            	EndIf
			EndIf

			If lRet .and. !oModelGrid:IsDeleted(nLinha)
				If oModelGrid:GetValue('RHB_TPMINF', nLinha) <> '20' .AND.  oModelGrid:GetValue('RHB_TPMINF', nLinha) <> '17' .AND. oModelGrid:GetValue('RHB_NUMINF', nLinhaAnt) <> oModelGrid:GetValue('RHB_NUMINF', nLinha)
					Help(" ",1,"RHB0014") // Movimento inválido ### A alteração de crédito Infonavit só é permitida se o tipo de movimento for igual a Modificação de Número de Crédito
					lRet := .F.
            	EndIf
			EndIf

			If lRet .and. !oModelGrid:IsDeleted(nLinha)
				If oModelGrid:GetValue('RHB_TPMINF', nLinha) == '20' .AND. oModelGrid:GetValue('RHB_NUMINF', nLinhaAnt) == oModelGrid:GetValue('RHB_NUMINF', nLinha)
					Help(" ",1,"RHB0015") // Movimento inválido ### Se o tipo de movimento for igual a Modificação de Número de Crédito, esse número deverá ser alterado!
					lRet := .F.
            	EndIf
			EndIf											

		EndIf

		//VALIDA VALORES
		If lRet .and. oModelGrid:GetValue('RHB_TIPINF', nLinha) == '1'
			If oModelGrid:GetValue('RHB_VALINF', nLinha) > 100
				Help(" ",1,"RHB00003") // Para tipo de Crédito Porcentagem SDI, só é permitido valores menores que 100 ### Inclua uma quantidade válida de acordo com o tipo de crédito selecionado
				lRet := .F.
			EndIf
		ElseIf lRet .and. oModelGrid:GetValue('RHB_TIPINF', nLinha) == '2'
			If oModelGrid:GetValue('RHB_VALINF', nLinha) > 99999
				Help(" ",1,"RHB00005") // Para tipo de Crédito Cota Fixa, só é permitido valores menores que 10.000,00 ### Inclua uma quantidade válida de acordo com o tipo de crédito selecionado
				lRet := .F.
			EndIf
		ElseIf lRet .and. oModelGrid:GetValue('RHB_TIPINF', nLinha) == '3'
			If oModelGrid:GetValue('RHB_VALINF', nLinha) > 1000
				Help( " ", 1, "Help",, "Problema: Para tipo de Crédito Salário Minímo, só é permitido valores menores que 1.000,00 Solução: Inclua uma quantidade válida de acordo com o tipo de crédito selecionado", 1, 0 )
			EndIf
		EndIf

		//VALIDA CÓDIGO REGISTRO PATRONAL
		dbSelectArea("RCO")
		dbSetOrder(1)
		If lRet .AND. !dbSeek(xFilial("RCO")+oModelGrid:GetValue('RHB_CODRPA', nLinha))
			Help(" ",1,"RHB0016") // Movimento inválido ### Código do Registro patronal não existe!
			lRet := .F.
		EndIf
		DbCloseArea()

	EndIf

EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} Gp910LiPre
Función que se encarga de detonar las validaciones previas de linea
@type function
@author eduardo.manriquez
@since 03/12/2021
@version 1.0
@param oModelGrid, object, Objeto que contiene el modelo utilizado en MVC
/*/
Static Function Gp910LiPre(oModelGrid)
	Local oModel    := oModelGrid:GetModel('RHBDETAIL')
	Local nOperation:= oModel:GetOperation()
	
	if !oModelGrid:IsDeleted()
		if nOperation == 4
			if oModelGrid:Length() > 0
				oModelGrid:loadValue("RHB_CODRPA", SRA->RA_CODRPAT)
			EndIf
		Endif
	Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp910PosVal ³ Autor ³ MOHANAD ODEH          ³ Data ³ 29/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos validacao de Crédito de Infonavit (TudoOk)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp910PosVal(oMdl)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdl = objeto do modelo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ModelDef()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp910PosVal(oModelGrid)
Local oModel     	:= oModelGrid:GetModel('RHBDETAIL')
Local nOperation	:= oModel:GetOperation()
Local aArea     	:= GetArea()
Local lRet 	   		:= .T.
Local lPri			:= .T.
Local nLinha		:= 0
Local nLinhaAnt		:= 0
Local nTotLin   	:= 0
Local n				:= 0
Local aRHBaCols 	:= AClone(oModel:aDataModel)

//GSA ASORT(oModel:aDataModel,,, { | x ,y| x[1, 1, 4] < y[1, 1, 4] } )
ASORT(oModel:aDataModel,2,, { | x ,y| dtos(x[1, 1, 5])+x[1, 1, 4] < dtos(y[1, 1, 5])+y[1, 1, 4] } ) //gsa //lemp

If nOperation == 4

	nTotLin := oModel:GetQtdLine()

	For nLinha:=1 to nTotLin

	        If lPri
	        	If !oModel:IsDeleted(nLinha)

					If oModel:GetValue('RHB_TPMINF', nLinha) <> '15'
						Help(" ",1,"RHB0008")  // Sequência de movimentos inválida ### O primeiro Movimento deve ser do tipo Início! Verifique a sequência lógica dos movimentos
						lRet := .F.
					EndIf
					lPri := .F.
				EndIf

	        Else

				nLinhaAnt	:= nLinha - 1

		        If lRet .and. oModel:IsDeleted(nLinha) .AND. oModel:IsDeleted(nLinhaAnt)
					Loop
				EndIf

		        If lRet .and. oModel:IsDeleted(nLinha) .AND. !oModel:IsDeleted(nLinhaAnt)
			        nLinhaAnt	:= nLinha - 1
			        For n := nLinha to nTotLin
			        	If !oModel:IsDeleted(n)
			        		nLinha := n
			        		Exit 
			        	EndIf
			        Next n
			    EndIf

				//VALIDA OS TIPOS MOVIMENTOS
				Do Case

					Case oModel:GetValue('RHB_TPMINF', nLinhaAnt) == '15' //Início

						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '15'
							Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
							lRet := .F.
						EndIf

						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '17'
							Help(" ",1,"RHB0009")   // Sequência de movimentos inválida ### Inclusão de Reinício só é permitida se houver uma suspensão
							lRet := .F.
						EndIf

					Case oModel:GetValue('RHB_TPMINF', nLinhaAnt) == '16' //Suspensão
					
						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) <> '17'
							Help(" ",1,"RHB00002") // Sequência de movimentos inválida ### Após um movimento de Suspensão só é permitido incluir um movimento de Reinício
							lRet := .F.
						EndIf

					Case oModel:GetValue('RHB_TPMINF', nLinhaAnt) == '17' //Reinício
	
						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '15'
							Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
							lRet := .F.
						EndIf

						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '17'
							Help(" ",1,"RHB0008")  // Sequência de movimentos inválida ### Já existe reinício para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
							lRet := .F.
						EndIf
	
					Case oModel:GetValue('RHB_TPMINF', nLinhaAnt) == '18' //Modificação do Tipo do Desconto

						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '15'
							Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
							lRet := .F.
						EndIf
	
						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '17'
							Help(" ",1,"RHB0008")  // Sequência de movimentos inválida ### Já existe reinício para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
							lRet := .F.
						EndIf

					Case oModel:GetValue('RHB_TPMINF', nLinhaAnt) == '19' //Modificação do Valor do Desconto
	
						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '15'
							Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
							lRet := .F.
						EndIf
	
						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '17'
							Help(" ",1,"RHB0008")  // Sequência de movimentos inválida ### Já existe reinício para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
							lRet := .F.
						EndIf

					Case oModel:GetValue('RHB_TPMINF', nLinhaAnt) == '20' //Modificação do Número de Crédito
	
						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '15'
							Help(" ",1,"RHB00001") // Sequência de movimentos inválida ### Já existe início para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
							lRet := .F.
						EndIf
	
						If lRet .and. oModel:GetValue('RHB_TPMINF', nLinha) == '17'
							Help(" ",1,"RHB0008")  // Sequência de movimentos inválida ### Já existe reinício para este movimento, não pode existir movimentos duplicados! Verifique a sequência lógica dos movimentos
							lRet := .F.
						EndIf

				EndCase
                     
				If lRet .and. !oModel:IsDeleted(nLinha)
					If oModel:GetValue('RHB_TPMINF', nLinha) == '16' .AND. (oModel:GetValue('RHB_NUMINF', nLinhaAnt) <> oModel:GetValue('RHB_NUMINF', nLinha);
						.OR. oModel:GetValue('RHB_TIPINF', nLinha) <> oModel:GetValue('RHB_TIPINF', nLinhaAnt).OR.;
								oModel:GetValue('RHB_VALINF', nLinha) <> oModel:GetValue('RHB_VALINF', nLinhaAnt))
						Help(" ",1,"RHB0010") // Movimento inválido ### Não é possível suspender um crédito diferente do vigente
						lRet := .F.
	            	EndIf
				EndIf

				If lRet .and. !oModel:IsDeleted(nLinha)
					If oModel:GetValue('RHB_TPMINF', nLinha) == '17' .And. !(oModel:GetValue('RHB_TPMINF', nLinhaAnt) == "16") 
						Help(" ",1,"RHB0011") // Movimento inválido ### Não é possível reiniciar um crédito diferente do suspenso!
						lRet := .F.
	            	EndIf
				EndIf

				If lRet .and. !oModel:IsDeleted(nLinha)
					If oModel:GetValue('RHB_TPMINF', nLinha) == '18' .AND. (oModel:GetValue('RHB_NUMINF', nLinhaAnt) <> oModel:GetValue('RHB_NUMINF', nLinha);
						.OR.oModel:GetValue('RHB_TIPINF', nLinha) == oModel:GetValue('RHB_TIPINF', nLinhaAnt))
						Help(" ",1,"RHB0012") // Movimento inválido ### Se o tipo de movimento for igual a Modificação de Tipo de Desconto, o Tipo de Desconto deve ser modificado, mantendo os dados do Movimento vigente  
						lRet := .F.
	            	EndIf
				EndIf
				
				If lRet .and. !oModel:IsDeleted(nLinha)
					If oModel:GetValue('RHB_TPMINF', nLinha) == '19' .AND. (oModel:GetValue('RHB_NUMINF', nLinhaAnt) <> oModel:GetValue('RHB_NUMINF', nLinha);
						.OR. oModel:GetValue('RHB_VALINF', nLinha) == oModel:GetValue('RHB_VALINF', nLinhaAnt))
						Help(" ",1,"RHB0013") // Movimento inválido ### Se o tipo de movimento for igual a Modificação do Valor do Desconto, o Valor do Desconto deve ser modificado, mantendo os dados do Movimento vigente
						lRet := .F.
	            	EndIf
				EndIf

				If lRet .and. !oModel:IsDeleted(nLinha)
					If oModel:GetValue('RHB_TPMINF', nLinha) <> '20' .AND.  oModel:GetValue('RHB_TPMINF', nLinha) <> '17' .AND. oModel:GetValue('RHB_NUMINF', nLinhaAnt) <> oModel:GetValue('RHB_NUMINF', nLinha)
						Help(" ",1,"RHB0014") // Movimento inválido ### A alteração de crédito Infonavit só é permitida se o tipo de movimento for igual a Modificação de Número de Crédito
					lRet := .F.
	            	EndIf
				EndIf

				If lRet .and. !oModel:IsDeleted(nLinha)
					If oModel:GetValue('RHB_TPMINF', nLinha) == '20' .AND. oModel:GetValue('RHB_NUMINF', nLinhaAnt) == oModel:GetValue('RHB_NUMINF', nLinha)
						Help(" ",1,"RHB0015") // Movimento inválido ### Se o tipo de movimento for igual a Modificação de Número de Crédito, esse número deverá ser alterado!
						lRet := .F.
	            	EndIf
				EndIf											


			EndIf

			If lRet .and. !oModel:IsDeleted(nLinha)
				//VALIDA VALORES
				If oModel:GetValue('RHB_TIPINF', nLinha) == '1'
					If oModel:GetValue('RHB_VALINF', nLinha) > 100
						Help(" ",1,"RHB00003") // Para tipo de Crédito Porcentagem SDI, só é permitido valores menores que 100 ### Inclua uma quantidade válida de acordo com o tipo de crédito selecionado
						lRet := .F.
					EndIf
				ElseIf lRet .and. oModel:GetValue('RHB_TIPINF', nLinha) == '2'
					If oModel:GetValue('RHB_VALINF', nLinha) > 99999
						Help(" ",1,"RHB00005") // Para tipo de Crédito Cota Fixa, só é permitido valores menores que 10.000,00 ### Inclua uma quantidade válida de acordo com o tipo de crédito selecionado
						lRet := .F.
					EndIf
				ElseIf lRet .and. oModel:GetValue('RHB_TIPINF', nLinha) == '3'
					If oModel:GetValue('RHB_VALINF', nLinha) > 1000
						Help(" ",1,"RHB00004") // Para tipo de Crédito Salário Minímo, só é permitido valores menores que 1.000,00 ### Inclua uma quantidade válida de acordo com o tipo de crédito selecionado
						lRet := .F.
					EndIf
				EndIf

			EndIf

			//VALIDA CÓDIGO REGISTRO PATRONAL
			dbSelectArea("RCO")
			dbSetOrder(1)
			If lRet .AND. !dbSeek(xFilial("RCO")+oModel:GetValue('RHB_CODRPA', nLinha))
				Help(" ",1,"RHB0016") // Movimento inválido ### Código do Registro patronal não existe!
				lRet := .F.
			EndIf
			DbCloseArea()

	Next

EndIf

oModel:aDataModel := aClone(aRHBaCols)

RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPEA910GRV   ³ Autor ³ MOHANAD ODEH         ³ Data ³ 22/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava nas tabelas de Credito Infonavit e Funcionarios        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPEA910GRV(oMdl)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdl = objeto do modelo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ModelDef()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPEA910GRV(oModelGrid)
Local oModel     	:= oModelGrid:GetModel('RHBDETAIL')
Local nOperation 	:= oModel:GetOperation()
Local aArea      	:= GetArea()
Local cQuery     	:= ''
Local cTmp			:= ''
Local nUltLin		:= 0

cFilInf := SRA->RA_FILIAL 
cMatInf := SRA->RA_MAT

nUltLin:= oModel:GetQtdLine()

FWFormCommit(oModelGrid)

If nOperation == 4
	cTmp    := GetNextAlias()

	cQuery := ""
	cQuery += "   SELECT MAX(RHB_DTMINF) AS RHB_DTMINF "
	cQuery += "        , RHB_TPMINF"
	cQuery += "     FROM " + RetSqlName('RHB') + "  "
	cQuery += "    WHERE RHB_FILIAL = '"+ xFilial('RHB') + "' "
	cQuery += "      AND RHB_TPMINF IN ('15', '16', '17', '18', '19', '20')"
	//gsa cQuery += "      AND  RHB_MAT = '" + AllTrim(FwFldGet('RHB_MAT')) + "' AND D_E_L_E_T_ = ' '"
	cQuery += "      AND  RHB_MAT = '" + 	AllTrim(oModel:GetValue('RHB_MAT'))  + "' AND D_E_L_E_T_ = ' '"	 //gsa
	cQuery += " GROUP BY RHB_TPMINF "

	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cTmp, .F., .T.)

	
	//Limpia valores de SRA para infonavit
		Begin Transaction
			DbSelectArea("SRA")
			If DbSeek(SRA->RA_FILIAL+SRA->RA_MAT)		
				RecLock("SRA",.F.,.T.)
				SRA->RA_NUMINF := space(TAMSX3("RA_NUMINF")[1]) 
				SRA->RA_TIPINF := space(TAMSX3("RA_TIPINF")[1])
				SRA->RA_VALINF := 0  
				SRA->RA_DTCINF := CTOD("//")  //Fch, Inico de Credito Infonavit
				SRA->RA_DTISINF:= CTOD("//")  //Fch. Susp de Credito Infonavit
				SRA->RA_DTRDINF:= CTOD("//")  //Fch. Rein Desc. de Credito Infonavit
				SRA->RA_DTMDINF:= CTOD("//")  //Fch. Modif. Tipo Descuento de Credito 
				SRA->RA_DTMVINF:= CTOD("//")  //Fch. Modif. Vlr Decuento de Credito 
				SRA->RA_DTMNINF:= CTOD("//")  //Fch. Modif. de No. de Credito Infonavit
   				MsUnlock()
				FKCOMMIT()    
			EndIf
		End Transaction 
	
	If !(cTmp)->(EOF())
		Begin Transaction
			DbSelectArea("SRA")  
			SRA->(DbSetOrder(1))
//gsa			If DbSeek(SRA->RA_FILIAL+AllTrim(FwFldGet('RHB_MAT')))
				// If DbSeek(SRA->RA_FILIAL+	AllTrim(oModel:GetValue('RHB_MAT')))			 //gsa
			If DbSeek(cFilInf+cMatInf)
				RecLock("SRA",.F.,.T.)
				SRA->RA_NUMINF := oModel:GetValue('RHB_NUMINF', nUltLin)
				SRA->RA_TIPINF := oModel:GetValue('RHB_TIPINF', nUltLin)
				SRA->RA_VALINF := oModel:GetValue('RHB_VALINF', nUltLin)
				While !(cTmp)->(EOF())	
					If (cTmp)->RHB_TPMINF == '15' .AND. !Empty((cTmp)->RHB_DTMINF)
						SRA->RA_DTCINF := STOD((cTmp)->RHB_DTMINF)
					EndIf
					If (cTmp)->RHB_TPMINF == '16' .AND. !Empty((cTmp)->RHB_DTMINF)
						SRA->RA_DTISINF := STOD((cTmp)->RHB_DTMINF)
					EndIf
					If (cTmp)->RHB_TPMINF == '17' .AND. !Empty((cTmp)->RHB_DTMINF)
						SRA->RA_DTRDINF := STOD((cTmp)->RHB_DTMINF)
					EndIf
					If (cTmp)->RHB_TPMINF == '18' .AND. !Empty((cTmp)->RHB_DTMINF)
						SRA->RA_DTMDINF := STOD((cTmp)->RHB_DTMINF)
					EndIf
					If (cTmp)->RHB_TPMINF == '19' .AND. !Empty((cTmp)->RHB_DTMINF)
						SRA->RA_DTMVINF := STOD((cTmp)->RHB_DTMINF)
					EndIf
					If (cTmp)->RHB_TPMINF == '20' .AND. !Empty((cTmp)->RHB_DTMINF)
						SRA->RA_DTMNINF := STOD((cTmp)->RHB_DTMINF)
					EndIf
					(cTmp)->(DbSkip())
				EndDo
				MsUnlock()
				FKCOMMIT()
			EndIf
		End Transaction  	
	EndIf

	RestArea(aArea)
EndIf

RETURN .t.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEA9101   ³ Autor ³Flor Monroy            ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validar tipo de movimiento 19                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA9101(oMdl)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdl = objeto del modelo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ModelDef()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPEA9101(oModelGrid)                                                                                                                      

Local lRet  :=.T.
Local oModel:= oModelGrid:GetModel('RHBDETAIL')
Local nLinha:= 0

nLinha:= oModelGrid:nLine
IF oModelGrid:GetValue('RHB_TPMINF', nLinha) $ '19' //19=Modificación del valor de Descuento
	oModelGrid:loadValue('RHB_NUMINF', oModelGrid:GetValue('RHB_NUMINF',if (nLinha-1==0,1,nLinha-1)))
	oModelGrid:loadValue('RHB_TIPINF', oModelGrid:GetValue('RHB_TIPINF', if (nLinha-1==0,1,nLinha-1)))
EndIf

IF oModelGrid:GetValue('RHB_TPMINF', nLinha) $ '16/17' //16=Suspension 17=Reinicio
	oModelGrid:loadValue('RHB_NUMINF', oModelGrid:GetValue('RHB_NUMINF', if (nLinha-1==0,1,nLinha-1)))
	oModelGrid:loadValue('RHB_TIPINF', oModelGrid:GetValue('RHB_TIPINF', if (nLinha-1==0,1,nLinha-1)))
	oModelGrid:loadValue('RHB_VALINF', oModelGrid:GetValue('RHB_VALINF', if (nLinha-1==0,1,nLinha-1)))	
EndIf
IF oModelGrid:GetValue('RHB_TPMINF', nLinha) $ '18' //18=Tipo de descuento
	oModelGrid:loadValue('RHB_NUMINF', oModelGrid:GetValue('RHB_NUMINF', if (nLinha-1==0,1,nLinha-1)))
endif
Return lRet
