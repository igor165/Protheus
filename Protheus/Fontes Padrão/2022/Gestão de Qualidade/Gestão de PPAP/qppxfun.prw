#INCLUDE "QPPXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FILEIO.CH'
#DEFINE Confirma 1
#DEFINE Redigita 2
#DEFINE Abandona 3 

// Funcoes renomeadas trazidas do QAXFUN, exclusiva para o modulo PPAP
// Robson Ramiro A. Oliveira 27/07/01
                                
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QO_TEXTO	� Autor � Vera / Wanderley 	    � Data � 01.12.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trata textos - VERSAO DOS/WINDOWS						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QO_TEXTO(ExpC1,ExpC2,ExpN1,ExpC3,ExpC4,ExpA1,ExpN2,ExpC5,; ���
���			 � 			ExpL1,ExpC6)									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Chave do Texto (j� convertida) 					  ���
���			 � ExpC2 = Especie do Texto									  ���
���			 � ExpN1 = Tamanho da linha do texto						  ���
���			 � ExpC3 = Titulo do Texto: somente informativo na tela		  ���
���			 � ExpC4 = Codigo do Titulo: somente informativo na tela 	  ���
���			 � ExpA1 = Array contendo os textos a serem editados		  ���
���			 � ExpN2 = Linha do vetor axTextos							  ���
���			 � ExpC5 = Cabecalho da tela de Texto						  ���
���			 � ExpL1 = Edita ou n�o o texto. 							  ���
���			 � ExpC6 = Alias do arquivo para gravar o texto 			  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � Generico 												  ���
�������������������������������������������������������������������������Ĵ��
���Obs		 � O vetor axTextos deve ser criado no programa chamador, como���
���			 � private, e passado via parametro, como referencia (@).	  ���
���			 � O vetor axTextos deve ser inicializado apos cada funcao de ���
���			 � inclusao,alteracao e exclusao.							  ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Robson Ramir �02.08.01�------� Alteracao no size da var Memo para ser ���
���              �        �      � calculado com base no nTamLin          ���
��� Robson Ramir �06.12.02�------� Acerto do tamanho do dialogo devido a  ���
���              �        �      � troca da fonte                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QO_TEXTO(cChave,cEspecie,nTamLin,cTit,cCod,axTextos,nLi,cCab,;
	lEdita,cAliasQKO)

Local oFontMet   	:= TFont():New("Courier New",6,0)
Local oFontDialog	:= TFont():New("Arial",6,15,,.T.)
Local oDlg
Local oTexto
Local cAlias		:= iif(cAliasQKO == Nil,"QKO",cAliasQKO)
Local cTexto
Local cDescricao
Local nOpcA 		:= 0
Local nPasso		:= 0
Local nLinTotal		:= 0
Local nPos			:= 0
Local nTamPix		:= Iif(nTamlin == 75, 2.6756, 2.79)

cAliasQKO := iif(cAliasQKO == Nil,"QKO",cAliasQKO)

Private lEdit := Iif(lEdita == NIL, .T., lEdita)

//���������������������������������������������������������������������Ŀ
//� Recupera Texto ja' existente (nLi e' a linha atual da getdados)     �
//�����������������������������������������������������������������������
cTexto := QO_RecTxt( cChave, cEspecie, nLi, nTamLin, cAliasQKO, axtextos)

DEFINE MSDIALOG oDlg FROM	62,100 TO 320,610 TITLE cCab PIXEL FONT oFontDialog

@ 003, 004 TO 027, 250 LABEL cTit OF oDlg PIXEL
@ 040, 004 TO 110, 250			   OF oDlg PIXEL

@ 013, 010 MSGET cCod WHEN .F. SIZE 185, 010 OF oDlg PIXEL

If lEdit  // Obs. Cada caracter Courier New 06 tem aproximadamente 2.6756 pixels num dialogo assim.
	@ 050, 010 GET oTexto VAR cTexto MEMO NO VSCROLL SIZE (nTamLin*nTamPix), 051 OF oDlg PIXEL
Else
	@ 050, 010 GET oTexto VAR cTexto MEMO READONLY NO VSCROLL SIZE (nTamLin*nTamPix), 051 OF oDlg PIXEL
Endif

oTexto:SetFont(oFontMet)

DEFINE SBUTTON FROM 115,190 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 115,220 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca = Confirma
	// Confirma
	lGrava	  := .T.
	nPos := ascan(axTextos, {|x| x[1] == nLi })
	If nPos == 0
		Aadd(axTextos, { nLi, cTexto } )
	Else
		axTextos[nPos][2] := cTexto
	Endif
EndIf

Return If(nOpca==Confirma,.T.,.F.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QO_Rectxt � Autor � Vera / Wanderley 	    � Data � 02.12.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Recupera um texto do arquivo de textos 					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QO_RecTxt(ExpC1,ExpC2,ExpN1,ExpN2,ExpC3,ExpA1)			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Chave do Texto (ja' convertida)                    ���
���			 � ExpC2 = Especie do Texto									  ���
���			 � ExpN1 = Linha da GetDados que esta posicionada	    	  ���
���			 � ExpN2 = Tamanho da linha do texto						  ���
���			 � ExpC3 = Alias do arquivo para leitura (QKO ou tempor.)	  ���
���			 �  Obs.:  Se for arq. temp., deve ter a mesma estrut. do QKO.���
���			 � ExpA1 = Array contendo o texto a ser recuperado 			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QO_TEXTO 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QO_Rectxt(cChave,cEspecie,nX,nTamLin,cAliasQKO,axTextos,lQuebra)
Local nPos	:= 0
Local cTexto:= ""
Local cAlias:= Iif(cAliasQKO == NIL,"QKO",cAliasQKO)
Local cQuebra:= Chr(13)+Chr(10)
Local nRec   := &(cAlias+"->(Recno())")
Local nOrd   := &(cAlias+"->(IndexOrd(IndexKey()))")

Default nX       := 1
Default nTamLin  := TamSx3("QKO_TEXTO")[1]
Default axTextos := {}
Default lQuebra  := .T.

If Len(axTextos) > 0
	nPos := ascan(axTextos,{ |x| x[1] == nX })
	If nPos <> 0
		cTexto:= axTextos[nPos][2]
	EndIf
EndIf

If nPos == 0
	dbSelectArea( cAlias )
	dbSetOrder(If(cAlias=="QKO",1,IndexOrd()))
	If dbSeek( xFilial(cAlias) + cEspecie + cChave )
		If Alltrim(cAlias) == "QKO" 
			While !Eof() .and. QKO->QKO_FILIAL+QKO->QKO_ESPEC+QKO->QKO_CHAVE == xFilial(cAlias)+cEspecie+cChave
				If At("\13\10",QKO->QKO_TEXTO) > 0
					cTexto+= SubStr(QKO->QKO_TEXTO,1,At("\13\10",QKO->QKO_TEXTO) - 1) + If(lQuebra,cQuebra,Space(1))
				Else
					// Para tratamento de postgress x linux
					If At("",QKO->QKO_TEXTO) > 0
						cTexto+= SubStr(QKO->QKO_TEXTO,1,At("",QKO->QKO_TEXTO) - 1) + cQuebra	
					Else
						cTexto+= RTrim(QKO->QKO_TEXTO)
					Endif	
				EndIf            
				QKO->(DbSkip())
			Enddo
		Endif
	EndIf
EndIf

&(cAlias+"->(dbGoTo("+Alltrim(Str(nRec))+"))")
&(cAlias+"->(dbSetOrder("+Alltrim(Str(nOrd))+"))")

Return(cTexto)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QO_GrvTxt � Autor � Vera / Wanderley 	    � Data � 02.12.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava o texto editado com QO_TEXTO, a partir do axTextos   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QO_GrvTxt(ExpC1,ExpC2,ExpN1,ExpA1,ExpC3)				      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Chave do Texto (j� convertida) 					  ���
���			 � ExpC2 = Especie do Texto									  ���
���			 � ExpN1 = Linha da Getdados que esta posicionado			  ���
���			 � ExpA1 = Vetor axTextos, que contem os textos digitados	  ���
���			 � ExpC3 = Alias do arquivo para gravacao (QKO ou tempor.)	  ���
���			 �  Obs.:  Se for arq. temp., deve ter a mesma estrut. do QKO.���
���			 � ExpN2 = Tamanho da linha na tela - Default 75 Carct.		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QO_GrvTxt(cChave,cEspecie,nX,axTextos,cAliasQKO,nTamLin)

Local cOldAlias	:= Select()
Local cTexto		:= ""
Local nI 			:= 0
Local nLinhas		:= {}
Local nPos			:= 0
Local nChr			:= 0
Local cAlias

Local cCampo 		:= "" // Auxiliar na grava��o, para gerar macro do campo

Default nTamLin		:= 75
Default cAlias 		:= "QKO"
Default axTextos	:= {}
Default cAliasQKO	:= "QKO"

If len(axTextos) > 0

	cTexto    := axTextos[1,2]
	nTamLin   := If(nTamLin >= Len(QKO->QKO_TEXTO),nTamLin-6,nTamLin)

	While !Empty(cTexto)
		cLine := Subs(cTexto,1,nTamLin)
		nTexto:= At(Chr(13),cLine)
		If nTexto > 0
			cLine := Subs(cLine,1,nTexto-1)+"\13\10"
			nTexto+= 2
		Else
			If !Empty(cLine)
				nTexto := nTamLin+1
			    nLen1 := Len(cLine)
				nLen2 := Len(Trim(cLine))
				
				//verifica se tem espaco no final da linha para colocar no inicio do proximo registro
				If nLen1 <> nLen2
					cLine := Trim(cLine)
					nTexto -= (nLen1 - nLen2)
				EndIf
			Else
				If Len(cTexto) > nTamLin
					nTexto := nTamLin+1
				Endif
			EndIf
		EndIf
		cTexto := Subs(cTexto,nTexto)
		aadd(nLinhas,cLine)
	EndDo
	
	dbSelectArea(cAliasQKO)
	dbSetOrder(1)
	dbseek(xFilial(cAliasQKO) + cEspecie + cChave)
	For nI := 1 to len(nLinhas)
		If Alltrim(cAliasQKO) == "QKO" 
			If !Eof() .and. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial(cAliasQKO)+cEspecie+cChave
				RecLock(cAliasQKO, .f.) // Lock
			Else
				RecLock(cAliasQKO, .t.) // Append
				cCampo  := cAliasQKO+"->"+cAliasQKO+"_FILIAL"
				&cCampo := xFilial(cAliasQKO)
				cCampo  := cAliasQKO+"->"+cAliasQKO+"_CHAVE"
				&cCampo := cChave
				cCampo  := cAliasQKO+"->"+cAliasQKO+"_ESPEC"
				&cCampo := cEspecie
			EndIf
			cCampo  := cAliasQKO+"->QKO_SEQ"
			&cCampo := StrZero(nI,3)
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_TEXTO" 
			&cCampo := nLinhas[nI]
			MsUnlock()
		Endif
		dbSkip()
	Next nI

	//�������������������������������������������������������������Ŀ
	//� Deleta as linhas anteriores se texto digitado for menor 	�
	//���������������������������������������������������������������
	If Alltrim(cAliasQKO) == "QKO" 	
		While QKO->(!Eof()) .And. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial('QKO')+cEspecie+cChave
			RecLock(cAliasQKO)
			dbDelete()
			MsUnlock()
			QKO->(dbSkip())
		Enddo
	Endif
Else
	cTexto    := "\13\10"
	dbSelectArea(cAliasQKO)
	dbseek(xFilial(cAliasQKO) + cEspecie + cChave)
	If Alltrim(cAliasQKO) == "QKO" 
		If !Eof() .and. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial(cAliasQKO)+cEspecie+cChave
			RecLock(cAliasQKO, .f.) // Lock
		Else
			RecLock(cAliasQKO, .t.) // Append
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_FILIAL"
			&cCampo := xFilial(cAliasQKO)
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_CHAVE"
			&cCampo := cChave
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_ESPEC"
			&cCampo := cEspecie
		EndIf
		cCampo  := cAliasQKO+"->QKO_SEQ"
		&cCampo := "001"
		cCampo  := cAliasQKO+"->"+cAliasQKO+"_TEXTO" 
		&cCampo := cTexto
		MsUnlock()
	Endif
EndIf

dbSelectArea(cOldAlias)

Return NIl


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QO_DelTxt � Autor � Vera / Wanderley 	    � Data � 04.12.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Deleta o texto editado com QO_TEXTO, a partir do axTextos. ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QO_DelTxt(ExpC1,ExpC2,ExpN1,ExpC3)						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Chave do Texto (j� convertida) 					  ���
���			 � ExpC2 = Especie do Texto									  ���
���			 � ExpC3 = Alias do arquivo para leitura (QKO ou tempor.)	  ���
���			 �  Obs.:  Se for arq. temp., deve ter a mesma estrut. do QKO.���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QO_DelTxt(cChave,cEspecie,cAliasQKO)

Local cOldAlias := Select()
Local cAlias

cAlias := Iif(cAliasQKO == NIL,"QKO",cAliasQKO)

//�������������������������������������������������������������Ŀ
//� Deleta o texto no QKO ou arq. temporario 				    �
//���������������������������������������������������������������
dbSelectArea(cAlias)
dbseek(xFilial(cAlias) + cEspecie + cChave)
While !Eof() .and. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial(cAlias)+cEspecie+cChave
	RecLock(cAlias, .f.) 
	dbDelete()        
	MsUnlock()
	dbSkip()
Enddo
FKCOMMIT()

dbSelectArea(cOldAlias)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �QPP_CRONO � Autor � Robson Ramiro A Olivei� Data � 06.09.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza Cronograma                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QPP_CRONO(ExpC1,ExpC2,ExpC3)			        			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Peca                           					  ���
���			 � ExpC2 = Revisao          								  ���
���			 � ExpC3 = ID da Atividade				                	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAPPAP 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP_CRONO(cPeca,cRev,cID)

Local aArea 	:= {}
Local aUsrMat	:= {}

aArea 	:= GetArea()
aUsrMat	:= QA_USUARIO()

DbSelectArea("QKZ")
DbSetOrder(3)
If DbSeek(xFilial("QKZ") + cID)

	DbSelectArea("QKP")
	DbSetOrder(3)

	If DbSeek(xFilial("QKP")+ cPeca + cRev + QKZ->QKZ_COD)
		RecLock("QKP",.F.)

		If Empty(QKP->QKP_MAT)
			QKP->QKP_FILMAT	:= aUsrMat[2]
			QKP->QKP_MAT 	:= aUsrMat[3]
		Endif
	
		If Empty(QKP->QKP_DTINI)
			QKP->QKP_DTINI := dDataBase
		Endif

		If Empty(QKP->QKP_DTPRA)  
			QKP->QKP_DTPRA := dDataBase
		Endif

		QKP->QKP_DTFIM  := dDataBase
		QKP->QKP_PCOMP  := "4"
		QKP->QKP_LEGEND := "BR_CINZA"

		MsUnlock()
	Endif
Endif

DbSelectArea("QKP")
DbSetOrder(1)
 
RestArea(aArea)

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �QPPVldAlt � Autor � Robson Ramiro A Olivei� Data � 22.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Verifica se o processo pode ser alterado                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QPPVldAlt(ExpC1,ExpC2) 			        			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Peca                           					  ���
���			 � ExpC2 = Revisao          								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAPPAP 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPPVldAlt(cPeca,cRev,cAprov)

Local aArea 	:= {}
Local lReturn	:= .T.
Local cRotina	:= Funname()

aArea 	:= GetArea()

DbSelectArea("QK1")
DbSetOrder(1)
DbSeek(xFilial("QK1")+ cPeca + cRev)

If QK1->QK1_STATUS <> "1"
	Alert(STR0001) //"O processo deve estar em aberto para ser alterado !"
	lReturn := .F.
Endif
If cRotina $ "QPPA120/QPPA130/QPPA131/QPPA150/QPPA160/QPPA170/QPPA180/QPPA190/QPPA200/QPPA210/QPPA340/QPPA350/QPPA360"
   	If !Empty(cAprov)
		If ALLTRIM(UPPER(cAprov)) <> ALLTRIM(UPPER(cUserName))
			DbSelectArea("QAA")
			DbSetOrder(6)
			If DbSeek(UPPER(cAprov))
				If QA_SitFolh()
					messagedlg(STR0002) //"O usu�rio logado n�o � o aprovador/respons�vel, para altera��o dever� estar logado com o usu�rio aprovador"
					lReturn:= .F. 
				Else
					DbSelectArea("QAA")
					DbSetOrder(6)
					If DbSeek(UPPER(cUserName)) 
						messagedlg(STR0003) //"O usu�rio logado n�o � o aprovador, mas o usu�rio aprovador est� inativo,ser� permitida a altera��o por outro usu�rio"
					
						lReturn:= .T.
					Else
						messagedlg(STR0004)//"O usu�rio logado n�o est� cadastrado no cadastro de usu�rios do m�dulo, portanto n�o poder� ser o aprovador")
					    lReturn:= .F.
					Endif
				Endif
			Endif
		Endif		    
	Endif 	
Endif

RestArea(aArea)

Return lReturn

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �QPPTAMGET � Autor � Robson Ramiro A Olivei� Data � 09.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o tamanho limite da GetDados                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QPPTAMGET(ExpC1, ExpN1)                        			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Campo a ser avaliado           					  ���
���          � ExpN1 = Tipo do retorno                					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAPPAP 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPPTAMGET(cCampo,nTipo)

Local nTam := 0
Local cTam := ""
Local nReturn

nTam := TamSx3(cCampo)[1]

cTam := Replicate('9',nTam)

If nTipo == 1
	nReturn := Val(cTam)
Elseif nTipo == 2
	nReturn := nTam
Endif

Return nReturn

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Funcao    � PPAPVld      � Autor � Robson Ramiro A. Olive� Data � 26.08.03 ���
�����������������������������������������������������������������������������Ĵ��
���Descricao � Validacao da digitacao, devido ao FreeForUse()                 ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPAPVld()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias para validacao ExistChav                         ���
���          � ExpC2 = Chave de pesquisa                                      ���
���          � ExpN1 = Ordem                                                  ���
���          � ExpC3 = Alias para validacao ExistCpo                          ���
���          � ExpN2 = Ordem                                                  ���
���          � ExpN3 = Tipo de verificacao                                    ���
���          � ExpN4 = Numero de caracteres finais a excluir                  ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � PPAP                                                           ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
/*/

Function PPAPVld(cAlias, cChave, nOrd, cAlias2, nOrd2, nTipo, nSizeCut)
Local lRetorno := .F.
Local cChaveX

Default cAlias2	 := "QK1"
Default nOrd	 := 1
Default nOrd2	 := 1
Default nTipo 	 := 1
Default nSizeCut := 3

If nTipo == 1
	cChaveX := cChave
Elseif nTipo == 2
	cChaveX := Subst(cChave,1,Len(cChave)-nSizeCut)
Endif

If ExistChav(cAlias,cChave,nOrd) .and. ExistCpo(cAlias2,cChaveX,nOrd2) .and. !Empty(cChave);
	.and. FreeForUse(cAlias, cChave)
	lRetorno := .T.
Endif

Return lRetorno

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Funcao    � PPALOAD      � Autor � Robson Ramiro A. Olive� Data � 06.01.04 ���
�����������������������������������������������������������������������������Ĵ��
���Descricao � Funcao criada para substituir o X2_ROTINA()                    ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPALoad()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                           ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � PPAP                                                           ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
/*/

Function PPALOAD()

QA_TravUsr()	// Trava usuario
QPP110Email()	// Dispara email
QPPC010(.T.)	// Checa pendencias

If GetMv("MV_QALOGIX") == "1" //Caso haja integracao com o Logix e exista alias QNB - verifica se tem inconsistencias nos WebServices
	If ChkFile("QNB")
		If GetMV("MV_QMLOGIX",.T.,"1") == "1" //Define se mostra a tela de inconsistencia 
		QXMSLOGIX()
		Endif
	Endif	
Endif	

Return Nil    

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Funcao    � PPALOAD      � Autor � Robson Ramiro A. Olive� Data � 06.01.04 ���
�����������������������������������������������������������������������������Ĵ��
���Descricao � Funcao criada para substituir o X2_ROTINA()                    ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPALoad()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                           ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � PPAP                                                           ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
/*/

Function PPAPLOAD()

/*
VISANDO MANTER  COMPATIBILIDADE COM OS OUTROS RELEASES DESTA VERSAO FOI DETERMINADO QUE A FUNCAO
PPAPLOAD CHAMARA A PPALOAD DESTA  FORMA CASO ESTA FUNCAO PRECISE DE ATUALIZACOES ESTAS NAO IRAO
PREJUDICAR O FUNCIONAMENTO DO MODULO EM OUTROS RELEASES.
ATENTAR PARA O FATO QUE AS ALTERACOES  DEVEM SER  FEITAS NA  FUNCAO ACIMA
*/
PPALOAD()

Return Nil

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Funcao    � PPAPBMP      � Autor � Robson Ramiro A. Olive� Data � 30.03.04 ���
�����������������������������������������������������������������������������Ĵ��
���Descricao � Retira o BMP do RPO e salva em local especifico e retorn T ou F���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPAPBMP()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Nome do BMP no RPO                                     ���
���          � ExpC2 = Path para salvar o arquivo                             ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � Quality                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
/*/

Function PPAPBMP(cNome, cPath)

Local lReturn := .F.

cNome := Upper(cNome)

If !File(cPath+cNome,0) // 0 Default, 1 Server, 2 Remote
	lReturn := Resource2File(cNome, cPath+cNome)
Endif

Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QPPXFUN   �Autor  �Renata Cavalcante   � Data �  05/25/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Valida��o da exclus�o                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Valida se a opera��o pode ser executada                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QPPVldExc(cRev,cAprov)

Local aArea 	:= {}
Local lReturn	:= .T.
Local cRotina	:= Funname()

aArea 	:= GetArea()

If cRotina $ "QPPA120/QPPA130/QPPA150/QPPA160/QPPA170/QPPA180/QPPA190/QPPA200/QPPA210/QPPA340/QPPA350/QPPA360"
   	If !Empty(cAprov)
		If ALLTRIM(UPPER(cAprov)) <> ALLTRIM(UPPER(cUserName))
			DbSelectArea("QAA")
			DbSetOrder(6)
			If DbSeek(UPPER(cAprov))
				If QA_SitFolh()
					messagedlg(STR0005) //"O usu�rio logado n�o � o aprovador/respons�vel, para exclus�o dever� estar logado com o usu�rio aprovador"
					lReturn:= .F. 
				Else
					DbSelectArea("QAA")
					DbSetOrder(6)
					If DbSeek(UPPER(cUserName)) 
						messagedlg(STR0006) //"O usu�rio logado n�o � o aprovador, mas o usu�rio aprovador est� inativo,ser� permitida a exclus�o por outro usu�rio"
					
						lReturn:= .T.
					Else
						messagedlg(STR0007)//"O usu�rio logado n�o est� cadastrado no cadastro de usu�rios do m�dulo, portanto n�o poder� ser o aprovador")
					    lReturn:= .F.
					Endif
				Endif
			Endif
		Endif		    
	Endif 	
Endif

RestArea(aArea)

Return lReturn