#include "Protheus.ch"
#Include 'FWMVCDEF.CH'
#Include 'tcfa005.CH'
/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    � TCFA005  � Autor � Emerson Campos                    � Data � 04/04/2012 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o �  Configuracao do Informe de Rendimento (RHX)                             ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � TCFA005()                                                                ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���Cecilia Car.�24/07/2014�TQEA22          �Incluido o fonte da 11 para a 12 e efetuada ���
���            �          �                �a limpeza.                                  ���
���Renan Borges�23/01/2015�TRILIZ          �Ajuste para validar o campo "Dia/Mes Inf."  ���
���            �          �                �corretamente.                               ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/
Function TCFA005 
	Local oBrwRHX

    oBrwRHX := FWmBrowse():New()		
	oBrwRHX:SetAlias( 'RHX' )
	oBrwRHX:SetDescription(STR0001)	//"Configuracao do Informe de Rendimento"		

	oBrwRHX:Activate()
Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef    � Autor � Emerson Campos        � Data � 04/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Menu Funcional                                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {}
 
	ADD OPTION aRotina Title STR0002  	Action 'PesqBrw'         	OPERATION 1 ACCESS 0	//"Pesquisar"
	ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.TCFA005' 	OPERATION 2 ACCESS 0	//"Visualizar"   
	ADD OPTION aRotina Title STR0004  	Action 'VIEWDEF.TCFA005' 	OPERATION 3 ACCESS 0	//"Incluir"
	ADD OPTION aRotina Title STR0005  	Action 'VIEWDEF.TCFA005' 	OPERATION 4 ACCESS 0	//"Alterar" 
	ADD OPTION aRotina Title STR0006  	Action 'VIEWDEF.TCFA005' 	OPERATION 5 ACCESS 0 	//"Excluir" 

Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ModelDef   � Autor � Emerson Campos        � Data � 04/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados e Regras de Preenchimento para o Configuracao���
���          � do Informe de Rendimento (RHX)                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRHX := FWFormStruct( 1, 'RHX', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oMdlRHX
		
	// Bloco de codigo da Fields
	Local bTOkVld		:= { |oGrid| RHXTOk( oGrid, oMdlRHX)}
		
	// Cria o objeto do Modelo de Dados
	oMdlRHX := MPFormModel():New('TCFA005', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oMdlRHX:AddFields( 'MODELRHXInf', /*cOwner*/, oStruRHX, /*bLOkVld*/, bTOkVld, /*bCarga*/ )
	
	// Adiciona a descricao do Modelo de Dados
	oMdlRHX:SetDescription(STR0001)	//"Configuracao do Informe de Rendimento"
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRHX:GetModel( 'MODELRHXInf' ):SetDescription(STR0001)	//"Configuracao do Informe de Rendimento"
		
Return oMdlRHX

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ViewDef    � Autor � Emerson Campos        � Data � 04/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados e Regras de Preenchimento para o Configuracao���
���          � do Informe de Rendimento (RHX)                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oMdlRHX   := FWLoadModel( 'TCFA005' )
	// Cria a estrutura a ser usada na View
	Local oStruRHX := FWFormStruct( 2, 'RHX' )
	Local oView
		
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlRHX )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_RHXInf', oStruRHX, 'MODELRHXInf' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_RHXInf', 'FORMFIELD' )

Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � RHXTOk     � Autor � Emerson Campos        � Data � 04/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � MValidacao da Fields                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � RHXTOk()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function RHXTOk( oGrid, oMdlRHX )
	Local lRet      := .T.
	Local nX
	Local cAnoBase	:= Space(4)
	Local nTam		:= Len(oMdlRHX:aModelStruct[1,3]:aDataModel[1])
		
	If oMdlRHX:GetOperation() == 3 .OR. oMdlRHX:GetOperation() == 4
		For nX := 1 To nTam 
			//Valida se o ano e positivo
			If oMdlRHX:aModelStruct[1,3]:aDataModel[1,nX,1] == "RHX_ANOBAS"
				If ! positivo(val(oMdlRHX:aModelStruct[1,3]:aDataModel[1,nX,2]))
					Help(" ", 1, "Help",, OemToAnsi(STR0007), 1, 0)	//"O ano informado n�o � v�lido!"
					lRet	:= .F.
					Exit
				Else
					cAnoBase	:= Soma1(oMdlRHX:aModelStruct[1,3]:aDataModel[1,nX,2])
				EndIf								 				
			EndIf			
		Next nX
		
		For nX := 1 To nTam
			//Valida o formato do dia mes da liberacao			
			If oMdlRHX:aModelStruct[1,3]:aDataModel[1,nX,1] == "RHX_DMLIBE"
				//Valida o dia informado
				If ! valDiaMes(oMdlRHX:aModelStruct[1,3]:aDataModel[1,nX,2],cAnoBase)
					Help(" ", 1, "Help",, OemToAnsi(STR0008), 1, 0) //""O dia informado no campo 'Dia/M�s da Libera��o', n�o corresponde a um dia v�lido para o m�s!"
					lRet	:= .F.
					Exit
				EndIf
				//Valida o mes informado
				If ! valMes(oMdlRHX:aModelStruct[1,3]:aDataModel[1,nX,2])
					Help(" ", 1, "Help",, OemToAnsi(STR0010), 1, 0) //"O m�s informado no campo 'Dia/M�s da Libera��o', n�o e um m�s v�lido!"
					lRet	:= .F.
					Exit
				EndIf
			EndIf
			
			//Valida o formato do dia mes do informe			
			If oMdlRHX:aModelStruct[1,3]:aDataModel[1,nX,1] == "RHX_DMINFO"
				//Valida o dia informado
				If ! valDiaMes(oMdlRHX:aModelStruct[1,3]:aDataModel[1,nX,2],cAnoBase)
					Help(" ", 1, "Help",, OemToAnsi(STR0009), 1, 0) //""O dia informado no campo 'Dia/M�s do Informe', n�o corresponde a um dia v�lido para o m�s!"
					lRet	:= .F.
					Exit
				EndIf				
				//Valida o mes informado
				If ! valMes(oMdlRHX:aModelStruct[1,3]:aDataModel[1,nX,2])
					Help(" ", 1, "Help",, OemToAnsi(STR0011), 1, 0) //"O m�s informado no campo 'Dia/M�s do Informe', n�o e um m�s v�lido!"
					lRet	:= .F.
					Exit
				EndIf
			EndIf
		Next nX
	EndIf 
Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � valDiaMes  � Autor � Emerson Campos        � Data � 04/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao dos campos de Dia e Mes                            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � valDiaMes()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cDiaMes - No formato DDMM                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function valDiaMes(cDiaMes, cAnoBase)
	Local lRet	:= .T.
	
	If SubStr(cDiaMes, 3, 2) $ ('01/03/05/07/08/10/12')
		If ! (Val(SubStr(cDiaMes, 1, 2)) >= 1 .AND. val(SubStr(cDiaMes, 1, 2)) <= 31) 
	   		lRet	:= .F.	   	
	   	EndIf	    				
	ElseIf SubStr(cDiaMes, 3, 2) $ ('04/06/09/11')
		If ! (Val(SubStr(cDiaMes, 1, 2)) >= 1 .AND. val(SubStr(cDiaMes, 1, 2)) <= 30) 
	   		lRet	:= .F.	   	
	   	EndIf
	Else	
		If (val(cAnoBase) % 4 > 0) .AND. ! (Val(SubStr(cDiaMes, 1, 2)) >= 1 .AND. val(SubStr(cDiaMes, 1, 2)) <= 28)
	   		lRet	:= .F.
	   	ElseIf (val(cAnoBase) % 4 == 0) .AND. ! (Val(SubStr(cDiaMes, 1, 2)) >= 1 .AND. val(SubStr(cDiaMes, 1, 2)) <= 29)
	   		lRet	:= .F.	   	
	   	EndIf
	EndIf
Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � valMes     � Autor � Emerson Campos        � Data � 04/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se o Mes informado e valido                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � valDiaMes()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cDiaMes - No formato DDMM                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function valMes(cDiaMes)
	Local lRet	:= .T.
    
	If !(Val(SubStr(cDiaMes, 3, 2)) >= 1 .AND. Val(SubStr(cDiaMes, 3, 2)) <= 12 )
		lRet	:= .F.	   	
	 EndIf
Return lRet