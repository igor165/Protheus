#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1155.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1155() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCMonitor                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Monitor do loja off-line                                               ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCMonitor
	Method New()
	Method Show()
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor                                                             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New() Class LJCMonitor
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Show                              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe o monitor.                                                       ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Show() Class LJCMonitor
	Local oLJCMessageManager := GetLJCMessageManager()
	Local oILMonitor		:= Nil
	Local oILPanel			:= Nil
	Local oDlg				:= Nil	
	Local oClient			:= Nil
	Local aCoors			:= FWGetDialogSize(oMainWnd)
			
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] STYLE nOr(WS_VISIBLE,WS_POPUP) PIXEL // "Monitor"		
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .T. )
	
	oFWLayer:AddCollumn( "Coluna 1", 100 )
	oFWLayer:AddWindow( "Coluna 1", "Window 1", STR0001, 100 ) // "Monitor"
	oLayer := oFWLayer:GetWinPanel( "Coluna 1", "Window 1" )	
	oLayer:ReadClientCoors( .T., .T. )
	
	aTFolder := { 'Carga' }
    oTFolder := TFolder():New( 0,0,aTFolder,,oLayer,,,,.T.,,(oLayer:nWidth/2),(oLayer:nHeight/2) )	     
    oILPanel := oTFolder:aDialogs[1]
		
	MsgRun( STR0003, STR0004, {|| oClient := GetLocalClient() } ) // "Pegando cliente do ambiente atual." "Aguarde..."
	
	If !oLJCMessageManager:HasMessage()
		oILMonitor := LJCInitialLoadMonitor():New( oClient )
		oILMonitor:Show( oILPanel )	
	Else
		oLJCMessageManager:Show( STR0005 ) // "N�o foi poss�vel abrir a aba de carga inicial."
		oLJCMessageManager:Clear()
	EndIf	
	
	ACTIVATE MSDIALOG oDlg CENTERED
Return
