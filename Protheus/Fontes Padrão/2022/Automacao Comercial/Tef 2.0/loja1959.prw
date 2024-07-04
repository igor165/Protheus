#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1959 ; Return  // "dummy" function - Internal Use  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCFrmMensagemTef�Autor�VENDAS CRM     � Data �  22/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe a mensagem retornada pelo Tef.                        ��� 
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCFrmMensagemTef

	Data cTpTef									//Tipo do tef utilizado
	Data cMensagem								//Mensagem do ECF
	
	Method New(cTpTef, cMensagem)
	
	//Metodos internos
	Method Show()    

EndClass         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  22/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cTpTef, cMensagem) Class LJCFrmMensagemTef  

	Self:cTpTef 	:= cTpTef
	Self:cMensagem 	:= cMensagem
	
	Self:Show()

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Show      �Autor  �Vendas Clientes     � Data �  22/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Abre a tela com a mensagem.							      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Show() Class LJCFrmMensagemTef

	Local oDlg		:= Nil								//Objeto dialog
	local oFontText	:= Nil								//Fonte do tipo de tef
	Local oFontMsg	:= Nil								//Fonte da mensagem
	Local oGet		:= Nil								//Objeto do tipo GET

	DEFINE FONT oFontText NAME "Verdana" SIZE 15,30 BOLD
	DEFINE FONT oFontMsg NAME "Arial" SIZE 10, 25 BOLD
	
	DEFINE MSDIALOG oDlg TITLE "Mensagem Tef" FROM 313,405 TO 550,825 PIXEL STYLE DS_MODALFRAME STATUS
			
		@ 005, 005 TO 30, 205 LABEL "" PIXEL OF oDlg  
		@ 013, 007 SAY ::cTpTef PIXEL SIZE 195,015 FONT oFontText CENTERED
				
		oDlg:lEscClose := .F.
				                                                    	
		@ 035,005 GET oGet VAR ::cMensagem COLOR CLR_GREEN FONT oFontMsg MEMO SIZE 200,65 PIXEL WHEN .F.
			
		DEFINE SBUTTON FROM 105, 180 TYPE 1 ENABLE OF oDlg ACTION (oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED    
	
Return Nil
