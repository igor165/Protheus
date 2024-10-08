#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFA012.CH"
/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � TCFA012  � Autor � Marinaldo de Jesus    � Data �20/12/2001�
�����������������������������������������������������������������������Ĵ
�Descri��o � Cadastrar mensagens para a empresa toda                    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   � TCFA012()                                                  �
�����������������������������������������������������������������������Ĵ
�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             �
�����������������������������������������������������������������������Ĵ
�Programador � Data   � BOPS �  Motivo da Alteracao                     �
�����������������������������������������������������������������������Ĵ
�Cecilia Car.�24/07/14�TQEA22�Incluido o fonte da 11 para a 12 e efetua-� 
�            �        �      �da a limpeza.                             � 
�������������������������������������������������������������������������*/
Function TCFA012()

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}	
Local aObjSize		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local cMsg			:= Space( 01 )
Local cFile			:= "TCFEMP.MSG"
Local nOk			:= 0.00
Local oFont
Local oDlg
Local oMemo

Private cCadastro := OemtoAnsi( STR0001 ) //"Mensagem Para Todos os Funcion�rios da Empresa"

IF File( cFile )
	IF Empty( cMsg := MemoRead( cFile ) )
		cMsg := Space( 01 )
	EndIF
EndIF

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

   	oMemo := TMultiget():New(aObjSize[1,1],aObjSize[1,2],{|u|if(Pcount()>0,cMsg:=u,cMsg)},;
                          oDlg,aObjSize[1,3],aObjSize[1,4],oFont,,,,,.T.,,,,,,.F.,,,,.T.)
	oMemo:lWordWrap:=.T.


	bSet15	:= { || nOk:=1, If ( Tcf012ok(cMsg), oDlg:End() , nOk:=2)  }
	bSet24	:= { || oDlg:End() }
	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

//Gravando a mensagem
IF ( nOk == 1 )
		While ( !( MemoWrit( cFile , cMsg ) ) .or. ( fError() != 0.00 ) )
			//"N�o Foi Possivel Gravar o Arquivo de Mensagens: "###
			//" Tentar Novamente? "###
			//"Aviso!"
			IF !( MsgYesNo( OemToAnsi( STR0002 ) + cFile + "." + OemToAnsi( STR0003 )  , OemToAnsi( STR0004 ) ) )
				//"A nova Mensasem n�o ser� gravada. Confirma?"
				IF ( MsgYesNo( OemToAnsi( STR0005 ) , OemToAnsi( STR0004 ) ) )
					Exit
				EndIF
			EndIF
		End While
EndIF
         
Return( NIL )

/*/
�����������������������������������������������������������������������������
��������������������������������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o    �Tcf012ok �        Autor � Fabio G.        															    � Data � 06.11.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o Tamanho de Mensagem      																						 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TCFA012                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tcf012ok(cMsg)
local lRet	:= .T.
	If len(cMsg) > 350 
		lRet := .F. 
		MsgInfo( OemToAnsi( STR0002 ) + OemToAnsi( STR0006 )  , OemToAnsi( STR0004 ) ) 
	EndIf	 
		
Return(lRet)    


