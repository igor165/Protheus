#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GPEA934B.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} function GPEA934B
Rotina para cadastramento de Obras Próprias eSocial na tabela RJ5
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
FUNCTION GPEA934B()

Local cFiltraRh 	:= ""
Local oBrwRJ5  
Local oDlg
Local nOpca 		:= 1
Local cMsgDesatu 	:= ""
Local aAreaRJ5		:= RJ5->(GetArea())
Local aDados		:= {}	

If !ChkFile("RJ5")
	cMsgDesatu := CRLF + OemToAnsi(STR0008) + CRLF
EndIf																														

If !Findfunction("fVldIniRJ")
	cMsgDesatu += CRLF + OemToAnsi(STR0009)
EndIf													

If !Empty(cMsgDesatu)
	//ATENCAO"###"Tabela RJ5 não encontrada na base de dados. Execute o UPDDISTR."
	//ATENCAO"###"Não foram encontradas atualizações necessárias para utilização desta rotina, favor atualizar o repositório."
	Help( " ", 1, OemToAnsi(STR0007),, cMsgDesatu, 1, 0 )
	Return 																	
EndIf

//Primeiro parâmetro da VldRotTab, quais eventos validar {S-1005, S-1010, S-1020}
If !VldRotTab({.F.,.F.,.T.},@aDados)
	Help( " ", 1, OemToAnsi(STR0007),, CRLF + aDados[1] + CRLF + CRLF + OemToAnsi(STR0015) + CRLF + OemToAnsi(STR0016), 1, 0) //Atenção # O compartilhamento da tabela (RJ5) e (C99) estão divergentes, altere o modo de acesso através do Configurador. Arquivos (RJ5) e (C99)
	//O modo de acesso deve ser o mesmo para todas as tabelas envolvidas no processo, são elas: RJ3, RJ4, RJ5, RJ6, C99 e C92."
	Return 		
EndIf

oBrwRJ5 := FWmBrowse():New()		
oBrwRJ5:SetAlias( 'RJ5' )
oBrwRJ5:SetDescription( STR0001 )   // "Relac. Centro de Custo X Lotações "

//Filtro padrao do Browse conforme tabela RJ5 (Relac. Centro de Custo X Lotações )
oBrwRJ5:SetFilterDefault(cFiltraRh)
oBrwRJ5:Activate()    

RestArea(aAreaRJ5)

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} function MenuDef
Rotina para definir o menu de rotinas 
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina Title STR0002  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.GPEA934B'	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.GPEA934B'	OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.GPEA934B'	OPERATION 4 ACCESS 0 //"Atualizar"
	ADD OPTION aRotina Title STR0006  Action 'VIEWDEF.GPEA934B'	OPERATION 5 ACCESS 0 //"Excluir"
	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} function ModelDef
Rotina para definir o modelo a ser utilizado 
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruRJ5 := FWFormStruct( 1, 'RJ5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
      
// Blocos de codigo do modelo
Local bPosValid 	:= { |oModel| GP394POSVAL( oModel ) }
Local bCommit 	  := { |oModel| GP934BGRV( oModel )   }

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('GPEA934B', /*bPreValid*/, bPosValid, bCommit, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'GPEA934B_MRJ5', /*cOwner*/, oStruRJ5, /*bLOkVld*/, /*bTOkVld*/, /*bCarga*/ )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:SetDescription( STR0001 )   //"Relac. Centro Custo x Lotações"

//--Valida se o model deve ser ativado
oModel:SetVldActivate( { |oModel| fVldModel(oModel,oModel:GetOperation()) } )
	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} function ViewDef
Rotina para definir a view a ser utilizada
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'GPEA934B' )

// Cria a estrutura a ser usada na View
Local oStruRJ5 := FWFormStruct( 2, 'RJ5' )
Local oView
Local lFilT := RJ5->( FieldPos( "RJ5_FILT" ) ) > 0

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona Grid na interface
oView:AddField( 'GPEA934B_VRJ5', oStruRJ5, 'GPEA934B_MRJ5' )

If lFilT 
	oStruRJ5:AddGroup( 'Grupo00', OemToAnsi(STR0024), '', 3 )   	  //'Dados Gerais'
	oStruRJ5:SetProperty( "RJ5_INI" 		, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRJ5:SetProperty( "RJ5_CC" 		    , MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRJ5:SetProperty( "RJ5_COD" 		, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRJ5:SetProperty( "RJ5_TPIO" 		, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRJ5:SetProperty( "RJ5_NIO" 		, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )

	//Configuração : Centro de Custo Único -> Lotações distintas
	oStruRJ5:AddGroup( 'Grupo01', OemToAnsi(STR0025), '', 3 )   	  //'Configuração : Centro de Custo Único -> Lotações distintas'
	oStruRJ5:SetProperty( "RJ5_FILT" 		, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
	
	//Acrescenta um objeto externo ao View do MVC
 	oView:AddOtherObject("OTHER_PANEL", {|oPanel| OpenLink(oPanel)})
Endif

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} function GP394POSVAL
Rotina para validar as informações antes de serem gravadas na base de
Dados
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function GP394POSVAL( oModel )
Local lRetorno   := .T.
Local nOperation
Local oMyMdl     := oModel:GetModel("GPEA934B_MRJ5")
Local cChave     := ""
Local nRECNO     := 0
Local lEncontrou := .F.
Local lFilT      := RJ5->( FieldPos( "RJ5_FILT" ) ) > 0

// Seta qual e a operacao corrente
nOperation := oModel:GetOperation()

nRECNO := RJ5->(RECNO())

If nOperation == 3 .or. ( nOperation == 4 .and. (oMyMdl:GetValue('RJ5_INI') + oMyMdl:GetValue('RJ5_CC') + oMyMdl:GetValue('RJ5_COD') <> RJ5->(RJ5_INI + RJ5_CC + RJ5_COD) ))

	cChave := oMyMdl:GetValue('RJ5_INI') + oMyMdl:GetValue('RJ5_CC') + oMyMdl:GetValue('RJ5_COD')

	dbSelectArea( "RJ5" )
	RJ5->(DBSETORDER(1))
	If dbSeek(xFilial("RJ5") + cChave)
		Help( ' ' , 1 , OemToAnsi(STR0007) , , OemToAnsi(STR0010) , 2 , 0 , , , , , , { OemToAnsi(STR0011) } )
		lRetorno := .F.
	EndIf
EndIf

DBGOTO(nRECNO)

IF lRetorno
	IF (nOperation == 3) .or. ( nOperation == 4 .and. (oMyMdl:GetValue('RJ5_INI') + oMyMdl:GetValue('RJ5_TPIO') + oMyMdl:GetValue('RJ5_NIO') + oMyMdl:GetValue('RJ5_CC') <> RJ5->(RJ5_INI + RJ5_TPIO + RJ5_NIO + RJ5_CC) .Or. (nOperation == 4 .And. lFilT .And. oMyMdl:GetValue('RJ5_FILT') <> RJ5->RJ5_FILT) ))

		cChave :=  (oMyMdl:GetValue('RJ5_INI') + oMyMdl:GetValue('RJ5_TPIO') + oMyMdl:GetValue('RJ5_NIO') + oMyMdl:GetValue('RJ5_CC'))

		dbSelectArea( "RJ5" )
		RJ5->(DBSETORDER(3))
		If dbSeek(xFilial("RJ5") + cChave)
			If (lFilT)
				While ((RJ5->(!Eof())) .And. (RJ5->RJ5_FILIAL + RJ5->RJ5_INI + RJ5->RJ5_TPIO + RJ5->RJ5_NIO + RJ5->RJ5_CC == xFilial("RJ5") + cChave) .And. (!lEncontrou))
					lEncontrou := ((oMyMdl:GetValue('RJ5_FILT') == RJ5->RJ5_FILT) .Or. (Empty(RJ5->RJ5_FILT)) .Or. (Empty(oMyMdl:GetValue('RJ5_FILT'))))

					RJ5->(DbSkip())
				Enddo
			Else
				lEncontrou := .T.
			Endif

			If (lEncontrou)
				Help( ' ' , 1 , OemToAnsi(STR0007) , , OemToAnsi(STR0012) , 2 , 0 , , , , , , {  OemToAnsi(STR0011) } )
				lRetorno := .F.
			Endif
		EndIf
	EndIf
EndIf

DBGOTO(nRECNO)

if lRetorno
	if (!empty(oMyMdl:GetValue('RJ5_TPIO')) .and. empty(oMyMdl:GetValue('RJ5_NIO') )) .or. (empty(oMyMdl:GetValue('RJ5_TPIO')) .and. !empty(oMyMdl:GetValue('RJ5_NIO') ))
		Help( ' ' , 1 , OemToAnsi(STR0007) , , OemToAnsi(STR0013) , 2 , 0 , , , , , , {  OemToAnsi(STR0014) } )
		lRetorno := .F.
	EndIf
EndIf

Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} function fVldModel
Rotina para ativar o model definido
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function fVldModel( oModel, nOperation )

Local lRetorno 	:= .T.

Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} function GP934BGRV
Rotina para gravas as informações na base de dados 
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function GP934BGRV(oModel)
Local lRet       := .T.
Local aArea      := GetArea()

FWFormCommit(oModel)
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function OpenLink
Rotina exibir link 
@author  Silvia Taguti
@since   04/11/20
@version V 1.0
/*/
//-------------------------------------------------------------------

Static Function OpenLink(oPanel)
Local oButton1

@ 083, 103 BUTTON oButton1 PROMPT OemToAnsi("?") SIZE 020, 010 OF oPanel PIXEL
oButton1:bLClicked := {|| ShellExecute("open","https://tdn.totvs.com/x/mFMFIg","","",1) }

Return Nil

