#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA900.CH"
#INCLUDE "INKEY.CH"

Static lIncluir:= .F.

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA900  � Autor � Jonatas A. T. Alves        � Data � 07/12/10 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Historico de Contratos                                          ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA900()                                                       ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � Esecifico                                                       ���
������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
������������������������������������������������������������������������������Ŀ��
���Programador � Data     � FNC / Chamado  � Motivo da Alteracao               ���
������������������������������������������������������������������������������Ĵ��
���Mohanad Odeh�13/03/2013�M12RH01 RQ3004  |Unificacao dos fontes V12          ���
���            �          �                |Removida as funcoes AjustaSX1 e Alt���
���Flavio Corr.�02/09/2014�TQMD57          |Retirada fun��o de checagem  campo ���
���Claudinei S.�03/06/2016�TUQEKD          |Conversao do fonte para MVC        ���
���Claudinei S.�08/07/2016�TUP136/TUQEKD   |Merge da 12.1.12                   ���
���C�cero Alves�01/09/2017�DRHPAG-256	   |Incluido tratamento do campo 	   ���
���			   �		  �				   |RGE_CALENC, que define os encargos ���
���            �          �    		 	   |que serao calculados.			   ���
���Eduardo K.  �28/09/2017�MPRIMESP-11588  |Ajuste em fTudoOKA90 para informar ���
���			   �		  �				   |o alias correto no ColumnPos       ���
���            �          �    		 	   |que serao calculados.			   ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function GPEA900()
Local aArea			:= GetArea()
Local aCoors		:= FWGetDialogSize( oMainWnd )
Local aCMP			:= {}
Local cIdBrowse
Local cIdGrid
Local cX3Campo		:= ""
Local oPanelUp
Local oTela
Local oPanelDown
Local oRelacRGE
Local oDlgPrinc
Local cFiltraRh  	:= ""

Private oBrowseUp
Private oBrowseDwn

Define MsDialog oDlgPrinc Title OemToAnsi(STR0001) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel  //"Historico de Contratos"

// Cria o conteiner onde ser�o colocados os paineis
oTela     := FWFormContainer():New( oDlgPrinc )
cIdBrowse := oTela:CreateHorizontalBox( 60 )
cIdGrid   := oTela:CreateHorizontalBox( 35 )

oTela:Activate( oDlgPrinc, .F. )

//Cria os paineis onde serao colocados os browses
oPanelUp  	:= oTela:GeTPanel( cIdBrowse )
oPanelDown	:= oTela:GeTPanel( cIdGrid )

cFiltraRH	:= ChkRh( "GPEA900" , "SRA" , "1" )
// FWmBrowse Superior: Funcionarios
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )                  	// Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( OemToAnsi(STR0018) )	//"Funcionarios"
oBrowseUp:SetAlias( 'SRA' )
oBrowseUp  :SetMenuDef( '' )              			// Define de onde virao os botoes deste browse
oBrowseUp:DisableDetails()
oBrowseUp:SetProfileID( '1' )
oBrowseUp:SetCacheView (.F.)
oBrowseUp:SetFilterDefault(cFiltraRH)
oBrowseUp:ExecuteFilter(.T.)

GpLegMVC(@oBrowseUp)

oBrowseUp:Activate()
// FWmBrowse Inferior: Cabecalhos do Funcion�rio
oBrowseDwn:= FWMBrowse():New()
oBrowseDwn:SetOwner( oPanelDown )
oBrowseDwn:SetDescription( OemToAnsi(STR0001) )	//"Hist�rico de Contratos"
oBrowseDwn:SetMenuDef( 'GPEA900' )
oBrowseDwn:DisableDetails()
oBrowseDwn:SetAlias( 'RGE' )
oBrowseDwn:SetProfileID( '2' )
oBrowseDwn:ForceQuitButton()					//sempre que existem dois menudefs na tela, deve-se indicar em qual browse vai ficar o botao 'Sair'
oBrowseDwn:SetCacheView (.F.)
oBrowseDwn:ExecuteFilter(.F.)

dbSelectArea("SX3")
SX3->(DbSetOrder(1))
dbSeek("RGE")

//--Carrega o array aCmp com os campos que dever�o aparecer no grid
While ! Eof() .and. (X3_ARQUIVO == "RGE")
	cX3Campo := X3_CAMPO
    If !X3USADO(X3_CAMPO) .Or. (ALLTRIM(X3_CAMPO) $ "RGE_NOME")
    	SX3->( DBSKIP() )
    	Loop
    EndIf
    aadd(aCmp,AllTrim(cX3Campo))
   	DbSkip()
EndDo
oBrowseDwn:SetOnlyFields(aCmp)
// Relacionamento entre os Paineis
oRelacRGE:= FWBrwRelation():New()
oRelacRGE:AddRelation( oBrowseUp  , oBrowseDwn , { { 'RGE_FILIAL', 'RA_FILIAL' }, { 'RGE_MAT' , 'RA_MAT'  } } )
oRelacRGE:Activate()
oBrowseDwn:Activate()
oBrowseUp:Refresh()
oBrowseDwn:Refresh()

Activate MsDialog oDlgPrinc Center

RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Leandro Drumond     � Data �  03/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Menu Funcional                                              ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAGPE                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef()
Local aRotina :=  {}

ADD OPTION aRotina TITLE STR0005 ACTION 'PesqBrw'          	OPERATION 1 ACCESS 0 DISABLE MENU //"Pesquisar"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GPEA900'	OPERATION 2 ACCESS 0 DISABLE MENU //"Visualizar"
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.GPEA900' 	OPERATION 4 ACCESS 0 DISABLE MENU //"Modificar"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.GPEA900' 	OPERATION 3 ACCESS 0 DISABLE MENU //"Incluir"
ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.GPEA900' 	OPERATION 5 ACCESS 0 DISABLE MENU //"Excluir"

Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Leandro Drumond       � Data � 11/12/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de Dados da Rotina                                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �ModelDef()                                                    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/

Static Function ModelDef()
Local oModel
Local oStruRGE
Local oStruSR9
Local oStruGET
Local bCommiA900	:= { | oModel | fCommit900(oModel) }
Local bTudoOK		:= { | oModel | fTudoOKA90(oModel,oModel:GetOperation()) }

oModel := MPFormModel():New( 'GPEA900', /*bPreValid*/, bTudoOK, bCommiA900)

oStruRGE := FWFormStruct(1,"RGE")
oModel:AddFields("GPEA900_RGE", /*cOwner*/, oStruRGE , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:SetPrimaryKey( {"RGE_FILIAL", "RGE_MAT","R_E_C_D_E_L_"} )

// Dados de Historico
oStruSR9 := FWFormStruct(1, "SR9")
// Quantidade de Dias de Prorrogacao
oStruSR9:AddField( ;
	AllTrim( OemToAnsi(STR0045)  ) , ;              // [01] Titulo do campo
	AllTrim( OemToAnsi(STR0045) )  , ;              // [02] ToolTip do campo
	"ZR9_DIAS"        	           , ;              // [03] Id do Field
	"N"                   		   , ;              // [04] Tipo do campo
	2                		       , ;              // [05] Tamanho do campo
	0                              , ;              // [06] Decimal do campo
	NIL                            , ;              // [07] Code-block de valida��o do campo
	NIL                            , ;              // [08] Code-block de valida��o When do campo
	NIL                            , ;        		// [09] Lista de valores permitido do campo
	NIL                            , ;              // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL                            , ;              // [11] Code-block de inicializacao do campo
	NIL                            , ;              // [12] Indica se trata-se de um campo chave
	NIL                            , ;              // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.      					     )              // [14] Indica se o campo � virtual
oModel:AddGrid("GPEA900_SR9", "GPEA900_RGE"/*cOwner*/, oStruSR9 , /*bLinePre*/, /* bLinePost*/, { |oModel| Gp900Dias(oModel) }/*bPre*/, /*bPos*/ ,/*bLoad*/)
oModel:GetModel('GPEA900_SR9'):SetOptional(.T.)
oModel:SetRelation("GPEA900_SR9",{{"R9_FILIAL",'xFilial("SR9")'},{"R9_MAT","RGE_MAT"}},SR9->(IndexKey()))

//--Valida se o model deve ser ativado
oModel:SetVldActivate( { |oModel| fVldModel(oModel,oModel:GetOperation()) } )

Return oModel

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Leandro Drumond       � Data � 11/12/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �View                                                          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �ViewDef()                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Static Function ViewDef()
Local oModel
Local oStructRGE
Local oView

oModel 	:= FwLoadModel("GPEA900")
oView 		:= FWFormView():New()
oView:SetModel(oModel)
oStructRGE := FWFormStruct(2,"RGE")
oView:AddField(  "GPEA900_RGE" , oStructRGE )

If cPaisLoc == "BRA"

	//GRUPOS DA ABA PERIODO DO CONTRATO
	oStructRGE:AddGroup( 'Grupo00', OemToAnsi(STR0019), '', 3 )   	  //'Dados Gerais'
	oStructRGE:SetProperty( "RGE_MAT" 		, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStructRGE:SetProperty( "RGE_NOME"		, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStructRGE:SetProperty( "RGE_CIC" 		, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )

	oStructRGE:AddGroup( 'Grupo01', OemToAnsi(STR0020), '', 3 )   	  //'Per�odo do Contrato'
	oStructRGE:SetProperty( "RGE_DATAIN" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
	oStructRGE:SetProperty( "RGE_DATAFI" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )

	//GRUPOS DA ABA RESIDENTE EXTERIOR
	oStructRGE:AddGroup( 'Grupo02', OemToAnsi(STR0021) , '', 3 )	  //'Dados do Contrato'

	If RGE->(ColumnPos( "RGE_RESEXT")) > 0
		oStructRGE:SetProperty( "RGE_RESEXT" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
	Endif

	oStructRGE:SetProperty( "RGE_NOMEMP" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
	oStructRGE:SetProperty( "RGE_CNPJ" 		, MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
	oStructRGE:SetProperty( "RGE_CODPAI" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
	oStructRGE:SetProperty( "RGE_BEDINI" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
	oStructRGE:SetProperty( "RGE_PAEXNI" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
	oStructRGE:SetProperty( "RGE_CODNIF" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
	// Altera picture do campo RGE_CODNIF para permitir informar letras
	oStructRGE:SetProperty( "RGE_CODNIF"	, MVC_VIEW_PICT			, '@!')

	oStructRGE:AddGroup( 'Grupo03', OemToAnsi(STR0022) , '', 3 )   //'Endere�o'
	oStructRGE:SetProperty( "RGE_LOGRAD" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
	oStructRGE:SetProperty( "RGE_NUMERO" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
	oStructRGE:SetProperty( "RGE_COMPL"  	, MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
	oStructRGE:SetProperty( "RGE_BAIRRO" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
	oStructRGE:SetProperty( "RGE_CODPOS" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
	oStructRGE:SetProperty( "RGE_CIDADE" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
	oStructRGE:SetProperty( "RGE_ESTPRO" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
	oStructRGE:SetProperty( "RGE_TELEFO" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo03' )

	oStructRGE:AddGroup( 'Grupo04', OemToAnsi(STR0023) , '', 3 )   //'Impostos'
	oStructRGE:SetProperty( "RGE_BENREN" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
	oStructRGE:SetProperty( "RGE_TIPREN" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
	oStructRGE:SetProperty( "RGE_FRMTRB" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
	oStructRGE:SetProperty( "RGE_CODRET" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
	oStructRGE:SetProperty( "RGE_DESCIR" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
	oStructRGE:SetProperty( "RGE_PERCIR" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
	oStructRGE:SetProperty( "RGE_DEDINS" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo04' )

	If RGE->( ColumnPos( "RGE_CALENC" ) ) > 0
		oStructRGE:SetProperty( "RGE_ENCARG" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
		oStructRGE:SetProperty( "RGE_CALENC" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
	EndIf

	If RGE->(ColumnPos( "RGE_TPREM" )) > 0
		oStructRGE:SetProperty( "RGE_TPREM" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
	Endif

	If RGE->(ColumnPos( "RGE_PDSAL" )) > 0
		oStructRGE:SetProperty( "RGE_PDSAL" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
	Endif

	oView:addUserButton( OemToAnsi(STR0043) + " (F6)","MAGIC_BMP", {|oView| Gp900Hist()}, OemToAnsi(STR0043) ,VK_F6, {MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW} ) // "Prorrogacoes (Arquivo BEm)"

Endif

oView:createHorizontalBox("FORMFIELD",100)
oView:SetOwnerView( "GPEA900_RGE","FORMFIELD")

Return(oView)

oView:SetCloseOnOk({ || .T. }) //Fecha tela apos commit

Return oView

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �fVldModel    � Autor � Leandro Drumond       � Data � 11/12/13 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Valida model e inicializa cabecalho SRG.                       ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �fVldModel(oModel,nOperation)                                   ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������/*/
Static Function fVldModel(oModel,nOperation)

Local lRet := .T.

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �fCommit900  � Autor � Leandro Drumond       � Data � 11/12/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que comita as informacoes, SEM abrir outra inclusao au-���
���          �tomaticamente.                                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �fCommit900(oModel)                                            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Static Function fCommit900(oModel)

FWFormCommit( oModel ) 					//--Grava model
oBrowseUp:Refresh()
oBrowseDwn:Refresh()

Return .T.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �fTudoOKA90  � Autor � Leandro Drumond       � Data � 11/12/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Validacoes acionadas ao clicar no botao confirma.             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �fTudoOKA90()                                                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Static Function fTudoOKA90(oModel,nOperation)
Local aArea     	:= GetArea()
Local lRet			:= .T.
Local oModelRGE 	:= oModel:GetModel('GPEA900_RGE')
Local aContrato		:= {}
Local nC			:= 0
Local lResidente	:= .F.
Local dCtIni		:= CtoD("")	// Data de Inicio do Contrato
Local dCtFim		:= CtoD("")	// Data de Termino do Contato
Local cCodNIF		:= ""			// NIF (Numero de Identificacao Fiscal)
Local cNomeEmp		:= ""			// Raz�o social
Local cCodPai		:= ""			// Pais do funcionario residente.
Local cBedini		:= ""			// Funcionario esta dispensado do NIF
Local cPaisNIF		:= ""			// Pais do funcionario exige o NIF
Local cTipRen		:= ""			// Tipo de Rendimento
Local cFrmTrib		:= ""			// Forma de Tributacao
Local cCodReten		:= ""			// Codigo de Retencao
Local lPDSAL		:= RGE->(ColumnPos( "RGE_PDSAL" )) > 0
Local lTPREM		:= RGE->(ColumnPos( "RGE_TPREM" )) > 0

FWModelActive( oModel )

dCtIni 	:= oModelRGE:GetValue("RGE_DATAIN")
dCtFim 	:= oModelRGE:GetValue("RGE_DATAFI")
cCodNIF 	:= oModelRGE:GetValue("RGE_CODNIF")
If RGE->(ColumnPos( "RGE_RESEXT")) > 0
	lResidente	:= oModelRGE:GetValue("RGE_RESEXT") = "1"
Else
	lResidente := .T.
Endif
//Campos que se tornam obrigat�rios caso o funcion�rio resida no exterior
cNomeEmp	:= oModelRGE:GetValue("RGE_NOMEMP")
cCodPai	:= oModelRGE:GetValue("RGE_CODPAI")
cBedini	:= oModelRGE:GetValue("RGE_BEDINI")
cPaisNIF	:= oModelRGE:GetValue("RGE_PAEXNI")
cTipRen	:= oModelRGE:GetValue("RGE_TIPREN")
cFrmTrib	:= oModelRGE:GetValue("RGE_FRMTRB")
cCodReten	:= oModelRGE:GetValue("RGE_CODRET")

If nOperation == MODEL_OPERATION_INSERT
	dbSelectArea( "RGE" )
	RGE->(DbSetOrder(2))
	dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
	While !Eof() .And. RGE->RGE_FILIAL+RGE->RGE_MAT == SRA->RA_FILIAL+SRA->RA_MAT
		aAdd(aContrato, { RGE->RGE_DATAIN, RGE->RGE_DATAFI })
		dbSkip()
	EndDo
	RestArea( aArea )

	If !Empty(dCtFim)
		For nC := 1 TO LEN( aContrato )
			If Empty(aContrato[nC,2])
				If dCtIni >= aContrato[nC,1]
					Help( " ", 1, "GPA900DT" )
					lRet := .F.
				Endif
			ElseIf (dCtIni >= aContrato[nC,1] .And. aContrato[nC,2] >= dCtIni );
			.Or. (dCtIni <= aContrato[nC,1] .And. dCtFim >= aContrato[nC,1] )
				Help( " ", 1, "GPA900DT" )
				lRet := .F.
			Endif
		Next nC
	Else
		For nC := 1 TO LEN( aContrato )
			If Empty(aContrato[nC,2])
				If dCtIni >= aContrato[nC,1] .Or. dCtFim >= aContrato[nC,1]
					Help( " ", 1, "GPA900DT" )
					lRet := .F.
				Endif
			ElseIf (dCtIni >= aContrato[nC,1] .And. aContrato[nC,2] >= dCtIni );
			.Or. (dCtIni <= aContrato[nC,1] .Or. dCtIni <= aContrato[nC,2])
				Help( " ", 1, "GPA900DT" )
				lRet := .F.
			Endif
		Next nC
	Endif
Endif

//Se for inclus�o ou altera��o, e o funcionaio for residente no exterior
If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. lResidente
	//Verifica o preenchimento do NIF
	lRet := If( ( cBedini == "1" .And. Empty(cCodNIF) ) .Or. ( cPaisNIF == "1" .And. cBedini == "1" .And. Empty(cCodNIF) ) .Or. ( cPaisNIF == "1" .And. cBedini == "2" .And. !Empty(cCodNIF) ) .Or. ( cPaisNIF == "2" .And. Empty(cCodNIF) ), .T., .F.  )
	If !lRet
		Help( " ", 1, "GPA900NIF" )
		lRet := .F.
	EndIf
	//Verifica o preenchimento dos campos que s�o obrigat�rios para residentes no exterior
	If Empty(cNomeEmp) .Or. Empty(cCodPai) .Or. Empty(cBedini) .Or. Empty(cPaisNIF) .Or. Empty(cTipRen) .Or. Empty(cFrmTrib) .Or. Empty(cCodReten)
		Help( " ", 1, "GPM900OBR" )
		lRet := .F.
	Endif
	If lRet .And. lTPREM .And. oModelRGE:GetValue("RGE_TPREM") == "1" .And. lPDSAL .And. Empty(oModelRGE:GetValue("RGE_PDSAL"))
		Help( ,, STR0046,, STR0047 , 1,,,,,,, {STR0048} ) //"Aten��o"##'Campo "Verba Pag." (RGE_PDSAL) n�o foi preenchido com o c�digo da verba para pagamento da remunera��o.'##'Informe o c�digo da verba para pagamento da remunera�ao no campo "Verba Pag." (RGE_PDSAL)"
		lRet := .F.
	EndIf
Endif

Return(lRet)

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gp900Nome 	  �Autor� Jonatas A. T. Alves � Data �02/12/2010�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna o nome completo do funcionario                      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>     								�
�����������������������������������������������������������������������Ĵ
�Uso       �GPEA900                                                  	�
�����������������������������������������������������������������������Ĵ
�Retorno   �cNome  														�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�������������������������������������������������������������������������/*/
Function Gpa900Nome()

Local cNome := ""

If SRA->( FieldPos( "RA_NOMECMP" ) ) > 0 .And. !Empty( SRA->RA_NOMECMP )
	cNome := SRA->RA_NOMECMP
Else
	cNome := SRA->RA_NOME
EndIf

Return( cNome )

/*/{Protheus.doc} ExistCCH
Valid dos campos RGE_CODPAI/RL_PAIS (GPEM560)
@param cCpo, caractere, Vari�vel de controle do conte�do a ser validado
@return lRet, logical, Retorna se encontrou o c�digo na tabela CCH conforme formato utilizado
/*/
Function ExistCCH(cCpo)
Local lRet := .T.
Local cAliasQry := GetNextAlias()
Local cWhere 	:= "% AND SUBSTRING(CCH.CCH_CODIGO,2,3) = '"

Default cCpo := ""
If Empty(cCpo)
	cWhere += M->RGE_CODPAI + "'%"
Else
	cWhere += cCpo + "'%"
EndIf
If ( TCGETDB() $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
	cWhere := STRTRAN(cWhere, "SUBSTRING", "SUBSTR")
EndIf

BeginSql alias cAliasQry
	SELECT CCH_CODIGO
	FROM 		%table:CCH% CCH
	WHERE 		CCH.%NotDel%
	 			%exp:cWhere%
				AND CCH.CCH_FILIAL = %exp:xFilial("CCH")%

EndSql
If ( (cAliasQry)->(Eof()) )
	lRet := .F.
	Help( " ", 1, "Help",, STR0011, 1, 0 ) //"C�digo de pa�s inv�lido"
EndIf

(cAliasQry)->(dbCloseArea())

Return lRet


/*/{Protheus.doc} Gp900CodEnc
Fun��o que retorna as op��es da consulta padr�o do campo RGE_CALENC
@author C�cero ALves
@since 01/09/2017
@version 1.0
@param l1Elem, logical, Vari�vel de controle da execu��o da consulta padr�o
@return lRet, lpgical, Retorna se montou a tela de sele��o de op��es
/*/
Function Gp900CodEnc(l1Elem)

	Local aSit		:= {}
	Local cMvPar
	Local cMvParDef	:= "123456789ABCDEFGHIJ"
	Local lRet		:= .T.

	l1Elem	:= IF( l1Elem == NIL .and. ValType( l1Elem ) != "L", .T., .F. )

	Aadd(aSit, "1" + "-" + STR0024)		//"Empresa"
	Aadd(aSit, "2" + "-" + STR0025)		//"Acid.Trab."
	Aadd(aSit, "3" + "-" + STR0042)		//"FGTS"
	Aadd(aSit, "4" + "-" + STR0026)		//"Terceiros"
	Aadd(aSit, "5" + "-" + STR0027)		//"Sal.Educ."
	Aadd(aSit, "6" + "-" + STR0028)		//"INCRA"
	Aadd(aSit, "7" + "-" + STR0029)		//"SENAI"
	Aadd(aSit, "8" + "-" + STR0030)		//"SESI"
	Aadd(aSit, "9" + "-" + STR0031)		//"SENAC"
	Aadd(aSit, "A" + "-" + STR0032)		//"SESC"
	Aadd(aSit, "B" + "-" + STR0033)		//"SEBRAE"
	Aadd(aSit, "C" + "-" + STR0034)		//"DPC"
	Aadd(aSit, "D" + "-" + STR0035)		//"F.AER."
	Aadd(aSit, "E" + "-" + STR0036)		//"SENAR"
	Aadd(aSit, "F" + "-" + STR0037)		//"SECONC"
	Aadd(aSit, "G" + "-" + STR0038)		//"SEST"
	Aadd(aSit, "H" + "-" + STR0039)		//"SENAT"
	Aadd(aSit, "I" + "-" + STR0040)		//"SESCOOP"
	Aadd(aSit, "J" + "-" + STR0041)		//"Adic.SENAI"

	If f_Opcoes(@cMvPar, "", aSit, cMvParDef, 12, 49, l1Elem, 1, Nil, Nil)
		VAR_IXB	:= cMvPar
		lRet 	:= .T.
	Else
		lRet := .F.
	EndIf

Return(lRet)

/*/{Protheus.doc} GP900Valid
Fun��o de valida��o do preenchimento do campo RGE_CALENC
@author C�cero ALves
@since 01/09/2017
@version 1.0
@Return lRet, logical, Retorna se o preenchimento est� correto
/*/
Function GP900Valid()

	Local cMvPar	:= &(Alltrim(ReadVar()))
	Local cMvParDef	:= "123456789ABCDEFGHIJ"
	Local cConteudo	:= If(Valtype(cMvPar) == Nil, "", cMvPar)
	Local lRet		:= .T.
	Local nTamLen	:= TamSX3("RGE_CALENC")[1]
	Local nX		:= 0

	cConteudo := SubStr( cConteudo, 1, nTamLen )
	cConteudo := StrTran( StrTran(cConteudo, " ", "*"), "*", "" )

	Begin Sequence

		//-- VERIFICA O RETORNO
		If (cMvPar != Nil)
			For nX := 1 To Len(cConteudo)
				If ! (SubStr(cConteudo, nX, 1) $ cMvParDef)
					lRet := .F.
					Break
				EndIf
			Next nX
		EndIf

	End Sequence

Return(lRet)

/*/{Protheus.doc} Gp900Hist
Fun��o para exibir historico de prorrogacoes sofridas pelo funcionario.
@author raquel.andrade
@since 22/09/2020
@version 1.0
@Return lRet, logical, Retorna se o preenchimento est� correto
/*/
Static Function Gp900Hist()

Local oView			:= Nil
Local oStructSR9 	:= Nil
Local oModel		:= FwLoadModel("GPEA900")
Local cCampo		:= "RGE_DTALT"

oViewSR9 := FWFormView():New()

oStructSR9 := FWFormStruct(2,"SR9")
oStructSR9:RemoveField("R9_CAMPO")
oStructSR9:RemoveField("R9_DATA")
oStructSR9:SetProperty("R9_DESC" ,MVC_VIEW_TITULO, OemToAnsi(STR0044)) //"Dt.Prorrogacao"

// Quantidade de Dias de Prorrogacao
oStructSR9:AddField( 				;
	"ZR9_DIAS"					    , ;                // [01] Campo
	"10"                			, ;                // [02] Ordem
	AllTrim( OemToAnsi(STR0045) )   , ;                // [03] Titulo
	AllTrim( OemToAnsi(STR0045) )   , ;                // [04] Descricao
	NIL                             , ;                // [05] Help
	"G"                             , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
	NIL  							, ;                // [07] Picture
	{||}                            , ;                // [08] PictVar
	Nil                             , ;                // [09] F3
	.T.  	                        , ;                // [10] Editavel
	Nil                				, ;                // [11] Folder
	Nil               				, ;                // [12] Group
	Nil                      		, ;                // [13] Lista Combo
	Nil                    			, ;                // [14] Tam Max Combo
	Nil               				, ;                // [15] Inic. Browse
	.T.     						)                  // [16] Virtual


oModel:SetRelation("GPEA900_SR9",{{"R9_FILIAL",'xFilial("SR9")'},{"R9_MAT","RGE_MAT"},{"R9_CAMPO","'" + cCampo + "'"}},SR9->(IndexKey()))

oViewSR9:SetModel(oModel)

oViewSR9:AddGrid("GPEA900_SR9", oStructSR9)
oViewSR9:CreateHorizontalBox("SR9", 100)
oViewSR9:SetOwnerView("GPEA900_SR9", "SR9")
oViewSR9:EnableControlBar(.T.)
oViewSR9:SetOperation(1)
oViewSR9:SetAfterViewActivate({|| oViewSR9:Refresh()})

oFWMVCWindow := FWMVCWindow():New()

oFWMVCWindow:SetUseControlBar(.T.)
oFWMVCWindow:SetView(oViewSR9)
oFWMVCWindow:SetCentered(.T.)
oFWMVCWindow:SetPos(0,0)
oFWMVCWindow:SetSize(380,700)
oFWMVCWindow:SetTitle(OemToAnsi(STR0043)) // "Prorrogacoes (Arquivo BEm)"
oFWMVCWindow:Activate()

Return Nil

/*/{Protheus.doc} Gp900Dias
Fun��o de pre validacao para carregar Dias de Prorrogacao
@author raquel.andrade
@since 22/09/2020
@version 1.0
@Return lRet, logical, Retorna se o preenchimento est� correto
/*/
Static Function Gp900Dias()
Local cDia			:= ""
Local cMes			:= ""
Local cAno			:= ""
Local lRet			:= .T.
Local dDtPrgAnt		:= CtoD("//")
Local i				:= 0
Local nLinBkp		:= 0
Local oModel		:= FwModelActive()
Local oGrid			:= oModel:GetModel("GPEA900_SR9")
Local nTamGrid		:= oGrid:Length()

If nTamGrid >= 1
	nLinBkp := oGrid:nLine
	For i := 1 To nTamGrid
			oGrid:GoLine(i)
			cDia 		:= SubStr(AllTrim(oGrid:GetValue("R9_DESC",oGrid:nLine)),1,2)
			cMes 		:= SubStr(AllTrim(oGrid:GetValue("R9_DESC",oGrid:nLine)),4,2)
			cAno 		:= SubStr(AllTrim(oGrid:GetValue("R9_DESC",oGrid:nLine)),7,4)
			dDtLinha	:= StoD(cAno+cMes+cDia)
			If nLinBkp == i
				dDtProg := dDtLinha
				dVigFim := RGE->RGE_DATAFI
				oGrid:LoadValue("ZR9_DIAS"	, dDtProg - dVigFim)
			ElseIf !(nLinBkp == i)
				dDtProg := dDtLinha
				cDia 		:= SubStr(AllTrim(oGrid:GetValue("R9_DESC",oGrid:nLine-1)),1,2)
				cMes 		:= SubStr(AllTrim(oGrid:GetValue("R9_DESC",oGrid:nLine-1)),4,2)
				cAno 		:= SubStr(AllTrim(oGrid:GetValue("R9_DESC",oGrid:nLine-1)),7,4)
				dDtPrgAnt	:= StoD(cAno+cMes+cDia)
				oGrid:LoadValue("ZR9_DIAS"	, dDtProg - dDtPrgAnt)
			EndIf
		Next i
		oGrid:GoLine(1)
	EndIf

Return lRet
