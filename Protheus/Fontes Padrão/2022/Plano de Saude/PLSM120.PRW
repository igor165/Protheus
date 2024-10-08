#INCLUDE "plsm120.ch"
#include "protheus.ch"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSM120 � Autor �Michele Tatagiba        � Data � 27.06.02 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Configuracao de Log de Campo                               ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSM120()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSM120()
      
AxCadastro("BIQ",STR0001) //"Configuracao de Log de Campo"
                                               
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PLSM120SEL� Autor �Michele Tatagiba       � Data � 27/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Seleciona arquivos                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �PLSM120                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSM120SEL()
Local oDlg,oLbx,oDel
Local oSav,nOAt:=0
Local lOK := .f., cRet
Local aConsulta,cLine,nPosLbx
Local cPesq:=Space(20),oPesq,nPosArq

Private aBancos:={}
cLine := ReadSqlMnu()	

// Monta array com os dados do SX2
If Len(aBancos) == 0
	DbSelectArea("SX2")
	DbGoTop()

	If Substr(cLine,1,1) = "." .or. Empty(cLine)
		While !Eof()
		
			If FWX2Chave() $ cFOPENED
				AADD(aBancos,{FWX2Chave(),AllTrim( X2Nome() ),.F.})
			EndIf
			DbSkip()
		End
	Else	
		While !Eof()
		
			If FWX2Chave()  $  cLine
				AADD(aBancos,{FWX2Chave(),AllTrim( X2Nome() ),.F.})
			EndIf		
			DbSkip()	
		End
	EndIf
EndIf

DEFINE MSDIALOG oDlg ;
	FROM  150,5 TO 358,361 ;
	TITLE OemToAnsi(STR0002) PIXEL //"Selecione o Arquivo"

@ 6,7 LISTBOX oLbx FIELDS HEADER "" , ;
	OemToAnsi(STR0003) SIZE 165, 63 ; //"Bases de Dados"
	OF oDlg PIXEL  ;
ON DBLCLICK ( If(ValidaUso(aBancos[oLbx:nAt,1]),;
( lOk := ValidSelect(@aBancos,oLbx:nAt,oDel),nPosLbx:=oLbx:nAt,oDlg:End() )	,))

oLbx:SetArray(aBancos)
oLbx:bLine := { || {aBancos[oLbx:nAt,1],aBancos[oLbx:nAt,2]}}

@ 75,10  SAY OemToAnsi(STR0004) SIZE 25, 7 OF oDlg PIXEL //"Pesquisar:"
@ 75,40 MSGET oPesq  VAR cPesq  SIZE 80,10 OF oDlg PIXEL PICTURE "@!" ;                                                                                                 
	VALID (nPosArq:=If(!Empty(cPesq),ASCAN(aBancos,{|z|AllTrim(cPesq)$z[1].OR.AllTrim(cPesq)$z[2]}),oLbx:nAt),If(nPosArq#0,oLbx:nAt:=nPosArq,MsgStop(OemtoAnsi(STR0005))),oLbx:Refresh(),If(nPosArq#0,nPosLbx:=nPosArq,),(nPosArq#0)) //"Dado nao encontrado"

// Define Botao Confirma
DEFINE SBUTTON FROM 90, 116 TYPE 1 ENABLE OF oDlg ;
 ACTION ( If(ValidaUso(aBancos[oLbx:nAt,1]),;
( lOk := ValidSelect(@aBancos,oLbx:nAt,oDel),nPosLbx:=oLbx:nAt,oDlg:End() )	,))

// Define Botao Cancelar
DEFINE SBUTTON FROM 90, 144 TYPE 2 ENABLE OF oDlg ACTION ( lOk := .f.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED VALID (nOAt := oLbx:nAt,.T.)

If lOk
   SX2->(DBSeek(aBancos[nOAt,1])) 
Endif

Return lOk


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ReadSqlMnu � Autor � 				    � Data �		  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � 														  	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function ReadSqlMnu()
Local cLine := ""
Local lLine := .F.

If Type("cArqMnu") != "C"
	cArqMnu := FWGetMnuFile()
EndIf

Ft_Fuse(cArqMnu)
FT_FGOTOP()
While !Ft_Feof()
	cLine:=FT_FREADLN()
	If "LERDA" $ Upper(cLine)
		cLine := Substr(cLine,32,90)
		lLine := .T.
		Exit
	EndIf
	Ft_fSkip()
End
If !lLine
	cLine := ""
EndIf
Ft_fUse()
Return cLine

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ValidSelec� Autor � Gilson Nascimento     � Data � 27/11/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a Selecao nos alias para nao duplicar os TABS       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � LERDA                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValidSelect(aBancos,nPos,oDel)
Local lRet := .T.
// Se ja foi selecionado, nao permite novamente
If aBancos[nPos][3]
	oDel:SetEnable()
	lRet := .F.
EndIf
aBancos[nPos][3] := .T.
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ValidaUso  � Autor � 				    � Data �		  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � 														  	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function ValidaUso(alias)
Local lUsado 	:= .F.
Local cAlias	:= Alias()
Local nOrdSX3	:= 0

DbSelectArea("SX3")
nOrdSX3	:= IndexOrd()
DbSetOrder(1)
DbGoTop()

DbSeek(alias)
While ( X3_ARQUIVO == alias )
	If(x3uso(x3_usado),lUsado := .T.,)
	DbSkip()
End
If !lUsado
	Help(" ",1,"NAO_USADO")
EndIf

DbSelectArea( 'SX3' )
DbSetOrder( nOrdSX3 ) 

If ( ! Empty( cAlias ) )
	DbSelectArea(cAlias)
EndIf

Return  lUsado   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ValX2Alias � Autor � Laercio Rodolfo     � Data � 18/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta o mesmo array aBancos da funcao PLSM120SEL para   	  ���
���	         � verificar se o que foi digitado no campo M->BCQ_ALIAS esta ���
���          � contido no array                                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Function ValX2Alias()

Local cFind    := M->BCQ_ALIAS
Local cAliasX2 := ""
Local cLine
Local aBancos  := {}
Local lRet     := .T.

cLine := ReadSqlMnu()	

If Len(aBancos) == 0
	DbSelectArea("SX2")
	DbGoTop()
	If Substr(cLine,1,1) = "." .Or. Empty(cLine)
		While !Eof()		
			If FWX2Chave() $ cFOPENED
				AADD(aBancos,{FWX2Chave(),AllTrim( X2Nome() ),.F.})
			EndIf
			DbSkip()
		End
	Else	
		While !Eof()		
			If FWX2Chave()  $  cLine
				AADD(aBancos,{FWX2Chave(),AllTrim( X2Nome() ),.F.})
			EndIf		
			DbSkip()	
		End
	EndIf
EndIf

If aScan(aBancos,{|x| x[1] == cFind}) == 0
	MsgInfo(OemToAnsi(STR0006))
	lRet := .F.
EndIf

Return(lRet)  