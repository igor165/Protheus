#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA010.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmkA010   ³ Autor ³ Vendas CRM		    ³ Data ³ 26/10/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa para atualizacao do cadastro de Motivos de ligação. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Void TmkA010(void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGATMK                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TmkA010()
Local oBrowse	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o Browse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AGK')
oBrowse:SetDescription(STR0001) // "Motivos de ligação"
oBrowse:Activate()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ModelDef  º Autor ³ Vendas CRM         º Data ³  26/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define o modelo de dados do grupo de atendimento (MVC)      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TmkA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()

Local oModel
Local oStruAGK := FWFormStruct(1,'AGK',/*bAvalCampo*/,/*lViewUsado*/)

oModel := MPFormModel():New('TMKA010',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AGKMASTER',/*cOwner*/,oStruAGK,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetDescription(STR0001)

Return(oModel)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   º Autor ³ Vendas CRM         º Data ³  26/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define a interface para cadastro de grupo de atendimento em º±±
±±º          ³MVC.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TmkA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('TMKA010')
Local oStruADW := FWFormStruct(2,'AGK')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_AGK', oStruADW,'AGKMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_AGK','TELA')

Return(oView)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³ Vendas CRM            ³ Data ³ 26/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de definicao do aRotina                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRotina   retorna a array com lista de aRotina              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TmkA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0008 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.TMKA010'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.TMKA010'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.TMKA010'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.TMKA010'	OPERATION 5	ACCESS 0


Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmkA010        º Autor ³ Vendas Cliente  º Data ³  11/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     | Programa para atualizacao do cadastro de Motivos de ligacao. º±± 
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP11                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß     
*/
Function TK010Anota( cCodOperador, lHouveInclusao, nCodGrupo,lMotObrig)
Local oDlgAnotacao		:= Nil
Local cMotivo			:= ""
Local nRet				:= 2
Local lRegistraMotivo	:= SuperGetMV( "MV_TMKANMO", , .F. )
Local lMotivoObrigatorio:= SuperGetMV( "MV_TMKOBAN", , .F. )
Local cInclusaoMotivo	:= SuperGetMV( "MV_TMKINMO", , "" )
Local nSaveSx8 			:= GetSX8Len()                      // Funcao de numeracao	
Local nGrupoACD			:= 0 /*Usa o Numero de B como DAC destino*/

If lMotObrig	
	If lRegistraMotivo .AND. ChkFile( "AGK" )
		DbSelectArea( "AGK" )
		DbSetOrder( 1 )
		 
		If Len(str(nCodGrupo)) > 4
			nGrupoACD := SubStr(str(nCodGrupo),len(str(nCodGrupo))-4,len(str(nCodGrupo)))
		Else
			nGrupoACD := nCodGrupo
		EndIf
		
		If lHouveInclusao .AND. !Empty( cInclusaoMotivo )
			cMotivo := cInclusaoMotivo
			nRet := 1
		Else	
			cMotivo := Space( TamSX3("AGK_MOTIVO")[1] )
			If AGK->(RecCount()) > 0					            
				While nRet == 2
					DEFINE MSDIALOG oDlg TITLE STR0002 FROM 0,0 TO 65,310 PIXEL // "Anotar ligação"
					
					@ 12,05  SAY STR0003 OF oDlg PIXEL SIZE 85,9 // "Informe o motivo da ligação:"
					@ 10,75  MSGET cMotivo F3 "AGK" VALID ExistCPO("AGK", cMotivo) OF oDlg PIXEL SIZE 30 ,9
					@ 10,110  BUTTON STR0004 SIZE 040,012 ACTION (nRet := 1,oDlg:End()) OF oDlg  PIXEL // "Gravar"
					
					ACTIVATE MSDIALOG oDlg CENTERED
					
					If nRet <> 1 .AND. lMotivoObrigatorio 
						Aviso( STR0005, STR0006, { STR0007 } ) // "Atenção!" "É necessário informar o motivo da ligação" "Continuar"
					ElseIf nRet <> 1 .AND. !lMotivoObrigatorio
						nRet := 1
					EndIf
				End              						
			EndIf
		EndIf
		
		If nRet == 1 .And. !Empty(cMotivo)
			RecLock( "AGL", .T. )
			Replace AGL->AGL_FILIAL With XFilial("AGL")
			Replace AGL->AGL_ANOTAC	With GetSXEnum("AGL","AGL_ANOTAC")
			Replace AGL->AGL_DATA	With DTOS(dDataBase)
			Replace AGL->AGL_HORA	With Time()
			Replace AGL->AGL_OPERAD	With cCodOperador
			Replace AGL->AGL_MOTIVO With cMotivo
			If cCurrentACDGroup <> ""
				Replace AGL->AGL_GRUPO	With val(cCurrentACDGroup)	//Veio pelo ponto de entrada (Somente PABX Digitro)
			Else
				Replace AGL->AGL_GRUPO	With val(nGrupoACD)			//Foi passado por parametro
			EndIf
			AGL->(MsUnLock())
			cCurrentACDGroup := ""					//Ja gravou o Grupo dessa chamada. Zera a variável.
			While (AGL->(GetSx8Len()) > nSaveSx8)
				AGL->(ConfirmSX8())
			End	
		EndIf			
	EndIf
EndIf	

Return