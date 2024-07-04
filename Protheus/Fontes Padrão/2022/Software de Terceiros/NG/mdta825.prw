#INCLUDE "MDTA825.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE _nVERSAO 1 //Versao do fonte
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA825  � Autor � Jackson Machado		  � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para o cadastro do Plano de Simulacao 				  ���
�������������������������������������������������������������������������Ĵ��
���Tabelas   �TJQ - Plano de Simulacao                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDTA825()
//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  	  �
//�������������������������������������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

If !NGCADICBASE("TBB_MODULO","A","TBB",.F.)
	If !NGCADICBASE("TJK_CODPLA","A","TJK",.F.)
		If !NGINCOMPDIC("UPDMDT38","TDGQ95")
			Return .F.
		Endif
	Endif

	Private aRotina := MenuDef()
	Private cCadastro := OemtoAnsi(STR0001)  //"Plano de Simula��o do Plano de Atendimento Emergencial"
	Private aChkDel := {}, bNgGrava  

	DbSelectArea("TJQ")
	DbSetOrder(1)
	mBrowse( 6, 1,22,75,"TJQ")
	
Else 

	SGAA240()

Endif

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK)                          �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return .t.                                                        

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT825SEQ � Autor � Jackson Machado		  � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para Incrementar o codigo do plano                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT825Sim(cAlias,nRecno,nOpcx)

nOpc := NgCad01(cAlias,nRecno,nOpcx)

If nOpc == 1
	Processa( { |lEnd| MDT825Simu() } )
EndIf	
Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT825SEQ � Autor � Jackson Machado		  � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para Incrementar o codigo do plano                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT825Seq()
Local cSeq := '000000'

DbSelectArea("TJQ")
DbSetOrder(1)
DbSeek(xFilial('TJQ')+TJQ->TJQ_CODPLA) 
If Inclui
	While TJQ->(!Eof()) .and. xFilial('TJQ') == TJQ->TJQ_FILIAL 
			   
	  	cSeq := TJQ->TJQ_CODPLA
		TJQ->(DbSkip())
	End	
	cSeq := StrZero(Val(cSeq)+1,6)
Else	                               
	cSeq := TJQ->TJQ_CODPLA
EndIf	 

Return cSeq

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT825SIMU� Autor � Jackson Machado		  � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para gerar Ordem de Simulacao.                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT825Simu()
Local nOrdem
Local nFreq := 0
Local dPrev := 0

Private dData,dReal
DbSelectArea("TJK")
DbSetOrder(1)
DbSeek(xFilial("TJK")+TJQ->TJQ_PLAINI,.t.)
nOrdem := 0
While !Eof()                          .And.;
   TJK->TJK_FILIAL == xFILIAL("TJK")  .And.;
   TJK->TJK_CODPLA >= TJQ->TJQ_PLAINI   .And.;
   TJK->TJK_CODPLA <= TJQ->TJQ_PLAFIM
   nRecno   := Recno()

   DbSelectArea("TJO")
   DbSetOrder(1)
   DbSeek(xFILIAL("TJO")+TJK->TJK_CODPLA)
	ProcRegua(RecCount())
   While !Eof() .And. TJO->TJO_FILIAL == xFILIAL('TJO')  .And.;
         TJO->TJO_CODPLA == TJK->TJK_CODPLA
			
		   dReal := TJO->TJO_DATPLA
		   nInc  := TJO->TJO_QUANTI
		   cFreq := TJO->TJO_FREQUE
		   cSeq  := TJO->TJO_SEQUEN

			If cFreq == '1'
				nFreq := nInc
			ElseIf cFreq == '2'
			   nFreq := nInc*30
			Else
			   nFreq := nInc*365
			EndIf
					   
		   dPrev := nFreq+dReal
		   
		   While dPrev < TJQ->TJQ_DATINI
		   	dPrev := nFreq+dPrev
		   End

 			While TJQ->TJQ_DATINI <= dPrev .and. TJQ->TJQ_DATFIM >= dPrev
 				IncProc(OemToAnsi(STR0002)) //"Gerando Ordem de Servico de Simulacao"
				MDT825GeraOs(dPrev)         						 
				dPrev := nFreq+dPrev
				nOrdem++
		   End
			DbSelectArea("TJO")			
			DbSkip()   
	End		   
	
	DbSelectArea("TJK")			
	DbSkip()   
End	                                                  

If nOrdem == 0
	MsgAlert(STR0003)  //"N�o foram geradas Ordens de Simula��o."
Else
	MsgAlert(STR0004+Str(nOrdem)+STR0005)  //"Foram geradas "###" Ordens de Simula��o."
EndIf                                       
Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT825SEQ � Autor � Jackson Machado		  � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para Incrementar o codigo do plano                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT825GeraOs(dData)
Local cUsu := AllTrim( SubStr( cUsuario, 7, 15 ) )

cOrdem := MDT825Ordem()
DbSelectArea("TJR")
DbSetOrder(1)
RecLock("TJR",.t.)

Replace TJR_FILIAL With xFilial("TJR")
Replace TJR_CODORD With cOrdem
Replace TJR_CODPLA With TJQ->TJQ_CODPLA
Replace TJR_DATPLA With TJQ->TJQ_DATPLA
Replace TJR_DATINP With dData
Replace TJR_PLAEME With TJO->TJO_CODPLA
Replace TJR_SEQUEN With TJO->TJO_SEQUEN
Replace TJR_DATSIM With dReal
Replace TJR_TERMIN With '2'
Replace TJR_SITUAC With '2'
DbSelectArea("SRA")
DbSetorder(6)
If DbSeek(xFilial("SRA")+cUsu)
	Replace TJR_USUARI With SRA->RA_MAT
EndIf
MsUnLock("TJR")


//Gravacao dos CheckLists Executados:             
DbSelectArea("TJP")
DbSetOrder(1)
DbSeek(xFILIAL("TJP")+TJO->TJO_CODPLA+TJO->TJO_SEQUEN)

While !Eof() .And. TJP->TJP_FILIAL  == xFILIAL("TJP") .And.;
	TJP->TJP_CODPLA  == TJO->TJO_CODPLA .And. TJP->TJP_SEQUEN == TJO->TJO_SEQUEN
   DbSelectArea("TJU")
   DbSetOrder(1)
   If !DbSeek(xFILIAL("TJU")+TJR->TJR_CODORD+TJR->TJR_CODPLA+TJP->TJP_CODCHK)
   	RecLock("TJU",.T.)
      TJU->TJU_FILIAL := xFILIAL("TJU")
      TJU->TJU_ORDEM  := TJR->TJR_CODORD
      TJU->TJU_PLANO  := TJR->TJR_CODPLA
      TJU->TJU_CHKLIS := TJP->TJP_CODCHK 
     	TJU->TJU_SEQCHK := TJP->TJP_SEQUEN
     	DbSelectArea("SRA")
		DbSetorder(6)
		If DbSeek(xFilial("SRA")+cUsu)
			TJU->TJU_USUARI := SRA->RA_MAT
		EndIf     	
      MsUnLock("TJU")
   EndIf
   DbSelectArea("TJP")
   Dbskip()
End
Return .t.
         
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT825SEQ � Autor � Jackson Machado		  � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para Incrementar o codigo do plano                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT825Ordem()
Local cOrdem := '000000'

DbSelectArea("TJR")
DbSetOrder(1)
DbSeek(xFilial("TJR"))

While !Eof() .and. xFilial("TJR") == TJR->TJR_FILIAL
	        
	cOrdem := TJR->TJR_CODORD
	DbSkip()
End

Return StrZero( Val( cOrdem )+1, 6 )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT825SEQ � Autor � Jackson Machado		  � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para Incrementar o codigo do plano                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT825Excl(cAlias,nRecno,nOpcx)

cCodPla := TJQ->TJQ_CODPLA
nOpc := NgCad01(cAlias,nRecno,nOpcx)

If nOpc == 1

   DbSelectArea('TJR')
   DbSetOrder(2)
   DbSeek(xFilial('TJR')+cCodPla)
   While !Eof() .And. xFilial('TJR') == TJR->TJR_FILIAL .And.;
      TJR->TJR_CODPLA == cCodPla
       
      RecLock("TJR",.f.)
      DbDelete()
      MsUnLock("TJR")
        
      DbSelectArea('TJR')
      DbSkip()
   End

EndIf
Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT825SEQ � Autor � Jackson Machado		  � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para Incrementar o codigo do plano                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT825Final(cAlias,nRecno,nOpcx)

If TJQ->TJQ_SITUAC == "1" .or. TJQ->TJQ_TERMIN = "1"
   Help("",1, "PLANJACANC")
   Return
EndIf

cCodPla := TJQ->TJQ_CODPLA

nOpc := NgCad01(cAlias,nRecno,nOpcx)

If nOpc == 1

	RecLock("TJQ",.F.)
	TJQ->TJQ_TERMIN := '1'
	TJQ->TJQ_SITUAC := '2'
	MsUnLock("TJQ")

   DbSelectArea('TJR')
   DbSetOrder(2)
   DbSeek(xFilial('TJR')+cCodPla)
   While !Eof() .And. xFilial('TJR') == TJR->TJR_FILIAL .And.;
      TJR->TJR_CODPLA == cCodPla
       
      RecLock("TJR",.f.)
      TJR->TJR_TERMIN := '1'
      TJR->TJR_SITUAC := '1'
      TJR->TJR_USUARI := AllTrim( SubStr( cUsuario, 7, 15 ) )
      TJR->TJR_OBSERV := 'A O.S '+TJR->TJR_CODORD+' foi cancelada dia '+DtoC( dDataBase )+;
      				       ' pelo usu�rio '+TJR->TJR_USUARI
      MsUnLock("TJR")
        
      DbSelectArea('TJR')
      DbSkip()
   End

EndIf
Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Jackson Machado		  � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ�� 
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina :=	{{STR0006,	"AxPesqui"  , 0 , 1}   ,; 		 //"Pesquisar"
                   {STR0007,	"NGCAD01"  , 0 , 2}   ,; 	 //"Visualizar"
                   {STR0008,	"MDT825Sim", 0 , 3}   ,; 	 //"Incluir"
                   {STR0009,	"MDT825Final" , 0 , 5, 3},;	  //"Finalizar"
                   {STR0010,	"MDT825Excl", 0 , 5, 3}} 		 //"Excluir"

Return aRotina
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �VALPLAFIM � Autor � Jackson Machado       � Data �20/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o campo plano fim	                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function VALPLAFIM()
If M->TJQ_PLAFIM = REPLICATE('Z',Len(TJQ->TJQ_PLAFIM)) 
	Return .T.
Else
	If MDT575CHKE('TJK','M->TJQ_PLAFIM','TJK->TJK_CODPLA')
		Return .T.
	Endif
Endif
If M->TJQ_PLAFIM < M->TJQ_PLAINI
	ShowHelpDlg(STR0011,{STR0012},2,{STR0013},2) //"ATEN��O"###"Plano Final menor que Plano Inicial."###"Favor informar um Plano FInal maior que o Inicial."
	Return .F.
Endif
Return .T.