#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA025.CH"

STATIC lMod2	:= .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINA025   �Autor  �Jair Ribeiro        � Data �  08/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Modalidades de pagamento                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN            	                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FINA025()
Local lContinua		:= .T.
Private cCadastro 	:= STR0001		//"Modo de Pagamento"
Private aRotina		:= MenuDef()

/*
 * Verifica��o do processo que est� configurado para ser utilizado no M�dulo Financeiro (Argentina)
 */
If lMod2
	If !FinModProc()
		Return()
	EndIf
EndIf

If lContinua
	DbSelectArea("FJS")
	FJS->(DbSetOrder(1))
	mBrowse(6,1,22,75,"FJS")
EndIf
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fin025Dlg �Autor  �Jair Ribeiro        � Data �  08/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de manutencao de modo de pagamento                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fin025Dlg(cAlias,nRecno,nOpc)
Local aDimensao	:= FWGetDialogSize(oMainWnd)
Local oDlg		:= Nil
Local oMsGet	:= Nil
Local bUpdate	:= {|| If(Obrigatorio(oMsGet:aGets,oMsGet:aTela) .And. Fin025Vld(nOpc),(Fin025Grv(nOpc),oDlg:End()),.F.)}
Local bEndWin	:= {|| oDlg:End()}

oDlg:= MSDialog():New(aDimensao[1],aDimensao[2],aDimensao[3],aDimensao[4],cCadastro,,,,,,,,,.T.)
	RegToMemory("FJS",(nOpc == 3))
	oMsGet := Msmget():New("FJS",,nOpc,,,,,{0,0,200,200},,,,,,oDlg)
	oMsGet:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
oDlg:Activate(,,,.T.,,,{|| EnchoiceBar(oDlg,bUpdate,bEndWin)})
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fin025Vld �Autor  �                    � Data � 31/10/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fin025Vld(nOpc)
Local lRet	:= .T.
Local lAux  := .T.

If cPaisLoc <> "BRA" 
	If ( cPaisLoc == "ARG" .AND. (ALLTRIM(M->FJS_TIPO)=="EF" .OR. ALLTRIM(M->FJS_TIPO)=="GR")  )
		lAux := .F.
	EndIf
EndIf

If cPaisLoc == "ARG" .and. nOpc == 3
	If M->FJS_TPVAL == " "
		Fin025TpVl()
		lRet := .F.
	Endif
Endif

If lAux
	If M->FJS_RCOP == "2"		//gera movimento bancario, deve informar o tipo de banco
		If Empty(M->FJS_TIPBCO)
			lRet := .F.
			MsgAlert(STR0015,STR0001) //"Para tipos que geram movimientos bancarios, deve-se informar o tipo de banco."###"Formas de Pagamento"
		Endif
	Endif
Endif
Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fin025Grv �Autor  �Jair Ribeiro	     � Data �  08/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza arquivo FJS                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Fin025Grv(nOpc)
Local bCampo	:= {|n| FieldName(n)}
Local nI		:= 0
Local lContinua := .T.

Begin Transaction
	FJS->(DbSetOrder(1))
	If FJS->(DbSeek( xFilial("FJS")+M->FJS_TIPO))
		If nOpc == 5
			FJS->(RecLock("FJS",.F.,.T.))
		ElseIf (nOpc == 3 .or. nOpc == 4)
			FJS->(RecLock("FJS",.F.))
		EndIf
	Else
		FJS->(RecLock("FJS",.T.))
	EndIf

	If (nOpc == 3 .or. nOpc == 4)
		For nI := 1 To FCount()
			FieldPut(nI,M->&(EVAL(bCampo,nI)))
		Next nI
		FJS->FJS_FILIAL	:= xFilial("FJS")
		If cPaisLoc <> "BRA"
			If M->FJS_RCOP <> "2"
				FJS->FJS_TIPBCO := " "
			Endif
		Endif
			FJS->(MsUnLock())
	ElseIf (nOpc == 5)
		lContinua := Fin025Del(FJS->FJS_TIPO)
		If lContinua
			FJS->(DbDelete())
			FJS->(MsUnLock())
		EndIf
	EndIf
End Transaction
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fin025Tipo�Autor  �Microsiga           �Fecha � 22/08/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna as formas de pagamento disponiveis                  ���
���          �                                                            ���
���          �Entrada:                                                    ���
���          �carteira - tipo de carteira (receber, pagar, ambas)         ���
���          �geracao - se gera movimento bancario ou titulos             ���
���          �terceiro - aceita, nao aceita, "tanto faz" documentos de 3o ���
���          �transito - aceita, nao aceita, "tanto faz" doc em transito  ���
���          �                                                            ���
���          �Retorno: array com os dados das formas de pagamento         ���
���          �[n,1] tipo                                                  ���
���          �[n,2] tipo interno                                          ���
���          �[n,3] descricao                                             ���
���          �[n,4] a gerar (1=titulo;2=movimento;3=certificado)          ���
���          �[n,5] carteira (1=receber;2pagar;3=ambas)                   ���
���          �[n,6] .T. aceita do em transito; .F. nao aceita             ���
���          �[n,7] .T. aceita doc 3os; .F. nao aceita doc 3os            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fin025Tipo(cCarteira,cGerar,cTerc,cTran)
Local cQuery	:= ""
Local cAliasFJS	:= ""
Local cCart		:= ""
Local cGer		:= ""
Local nGer		:= 0
Local aGerar	:= {}
Local aCart		:= {}"
Local aRet		:= {}
Local aArea		:= {}

Default cCarteira	:= "1,2,3"		//carteiras a receber e a pagar
Default cGerar		:= "1,2,3"		//geram movimento bancario, titulo, certificados
Default cTran		:= "3"			//aceita documentos em transito
Default cTerc		:= "3"			//aceita documentos de terceiros

aArea := GetArea()
aCart := {"1","2","3"}
For nGer := 1 To Len(aCart)
	If At(aCart[nGer],cCarteira) > 0
		If !Empty(cCart)
			cCart += ","
		Endif
		cCart += "'" + aCart[nGer] + "'"
	Endif
Next
If Empty(cCart)
	cCart := "''"
Endif
/**/
aGerar := {"1","2","3"}		//geram movimento bancario, titulo, certificado
For nGer := 1 To Len(aGerar)
	If At(aGerar[nGer],cGerar) > 0
		If !Empty(cGer)
			cGer += ","
		Endif
		cGer += "'" + aGerar[nGer] + "'"
	Endif
Next
If Empty(cGer)
	cGer := "''"
Endif
/**/
cQuery := "select FJS_TIPO,FJS_DESC,FJS_RCOP,FJS_CARTE,FJS_TRANS,FJS_TERCEI,FJS_TIPOIN"
If cPaisLoc <> "BRA"
	cQuery += ",FJS_TPVAL "
EndIf
cQuery += " from " + RetSQLName("FJS")
cQuery += " where FJS_FILIAL = '" + xFilial("FJS") + "'"
cQuery += " and FJS_BLOQ in ('2',' ')"
cQuery += " and FJS_CARTE in (" + cCart + ")"
cQuery += " and FJS_RCOP in (" + cGer + ")"
If cTran == "2"
	cQuery += " and FJS_TRANS <> '1'"
Else
	If cTran == "1"
		cQuery += " and FJS_TRANS == '1'"
	Endif
Endif
If cTerc == "2"
	cQuery += " and FJS_TERCEI = '4'"
ElseIf cTerc == "1"
	cQuery += " and FJS_TERCEI <> '4'"
Endif
cQuery += " and D_E_L_E_T_=''"
cAliasFJS := GetNextAlias()
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFJS)
(cAliasFJS)->(DbGoTop())
While !((cAliasFJS)->(Eof()))
	Aadd(aRet,{(cAliasFJS)->FJS_TIPO,(cAliasFJS)->FJS_TIPOIN,(cAliasFJS)->FJS_DESC,(cAliasFJS)->FJS_RCOP,FJS_CARTE,((cAliasFJS)->FJS_TRANS == "1"),((cAliasFJS)->FJS_TERCEI <> "4"),Iif(cPaisLoc <> "BRA",(cAliasFJS)->FJS_TPVAL,"")})
	(cAliasFJS)->(DbSkip())
Enddo
DbSelectArea(cAliasFJS)
DbCloseArea()

RestArea(aArea)
Return(Aclone(aRet))


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINA025   �Autor  �Microsiga           � Data �  06/21/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fin025TRec()

Local aText := {}
Local aButtons := {}
Local nOpca := 0


Aadd(aText,STR0008) //"Este processo ir� reclassificar a configura��o de Doc. de Terceiros dos Modo de Pago."

Aadd(aButtons, { 01,.T.,{|o| nOpca :=1, o:oWnd:End()}})
Aadd(aButtons, { 02,.T.,{|o| o:oWnd:End()}})
FormBatch(STR0001,aText,aButtons)

If nOpca == 1
	Processa({|| Fin025Recl() })
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINA025   �Autor  �Microsiga           � Data �  06/20/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fin025Recl()

Local aAreaFJS := {}

dbSelectArea("FJS")
aAreaFJS := FJS->(GetArea())
FJS->(dbGoTop())

If !FJS->(Eof()) .AND. !FJS->(Bof())
	//Varre todos os registros, alterando a configura��o de acordo com a carteira
	While !FJS->(Eof())

	    IncProc(STR0010+FJS->FJS_TIPO) ///Atualizando Modo de Pago:

		RecLock("FJS",.F.)
		Do Case
			//Carteira a Receber e Terceiro = Sim --> Terceiro = Receber
			Case AllTrim(FJS->FJS_CARTE) == "1" .And. AllTrim(FJS->FJS_TERCEI) == "1"
				FJS->FJS_TERCEI := "1" //Receber
			//Carteira a Pagar e Terceiro = Sim --> Terceiro = Pagar
			Case AllTrim(FJS->FJS_CARTE) == "2" .And. AllTrim(FJS->FJS_TERCEI) == "1"
				FJS->FJS_TERCEI := "2" //Pagar
			//Todas as Carteiras e Terceiro = Sim --> Terceiro = Receber
			Case AllTrim(FJS->FJS_CARTE) == "3" .And. AllTrim(FJS->FJS_TERCEI) == "1"
				FJS->FJS_TERCEI := "3" //Todas
			Case AllTrim(FJS->FJS_CARTE) $ "123" .And. AllTrim(FJS->FJS_TERCEI) == "2"
				FJS->FJS_TERCEI := "4" //Nenhuma
		EndCase
	    FJS->(MsUnlock())
		FJS->(dbSkip())
	EndDo

	FJS->(RestArea(aAreaFJS))
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINA025   �Autor  �Microsiga           � Data �  06/20/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fin025VlTc()

Local lRet := .T.


//FJS_TERCEI = 4 --> Para todas as configura��es de FJS_CARTE - sem restri��es;
//FJS_TERCEI = 3 --> Para FJS_CARTE = 3 - Todas;
//FJS_TERCEI = 2 --> Para FJS_CARTE = 2 - Pagar ou FJS_CARTE = 3 - Todas;
//FJS_TERCEI = 1 --> Para FJS_CARTE = 1 - Receber ou FJS_CARTE = 3 - Todas.

If !Empty(M->FJS_TERCEI)
	Do Case
		Case AllTrim(M->FJS_CARTE) == "1" .And. !(AllTrim(M->FJS_TERCEI) $ "14")
			MsgAlert(STR0011+STR0012) //"Conf. de Documento de Terceiro inv�lida para a carteira a Receber"
			lRet := .F.
		Case AllTrim(M->FJS_CARTE) == "2" .And. !(AllTrim(M->FJS_TERCEI) $ "24")
			MsgAlert(STR0011+STR0013) //"Conf. de Documento de Terceiro inv�lida para a carteira a Pagar"
			lRet := .F.
	EndCase
Else
	//Caso n�o seja selecionada nenhuma configura��o, atribui-se "Nenhuma"
	M->FJS_TERCEI := "4"
EndIf


Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINA025   �Autor  �Microsiga           � Data � 31/10/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fin025RCOP()
Local lRet	:= .T.

lRet := M->FJS_RCOP $ "123"
If lRet
	If cPaisLoc <> "BRA"
		If M->FJS_RCOP <> "2"
			M->FJS_TIPBCO := " "
		Endif
	Endif
Endif
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINA025   �Autor  �Microsiga           � Data �  06/20/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fin025Elt()

Local lRet := .T.

If !(M->FJS_TIPOIN $ MVCHEQUE+"|TF") .And. M->FJS_PGTELT == "1"
	lRet := .F.
	Alert(STR0014)//"O tipo interno configurado n�o aceita pagamento eletr�nico."
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fin025TpVl�Autor  �Marcos Berto        � Data �  30/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o tipo do valor contra o campo FJS_TIPOIN           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fin025TpVl()

Local lRet := .T.

Do Case
	Case M->FJS_TIPOIN $ MVCHEQUE .And. Empty(M->FJS_TPVAL)
		lRet := .F.
		Alert(STR0016) //"O tipo de valor deve ser informado para os cheques."
	Case AllTrim(M->FJS_TIPOIN) == "DC" .And. M->FJS_TPVAL <> "2"
		lRet := .F.
		Alert(STR0017) //"O tipo de valor diferido deve ser informado para os documentos."
	Case AllTrim(M->FJS_TIPOIN) == "EF" .And. M->FJS_TPVAL <> "1"
		lRet := .F.
		Alert(STR0018) //"O tipo de valor � vista deve ser informado para pagamentos em dinheiro."
		M->FJS_TPVAL := "1"
	Case !(AllTrim(M->FJS_TIPOIN) $ MVCHEQUE+"DC|EF") .And. M->FJS_TPVAL <> ""
		lRet := .F.
		Alert(STR0019) //"Para o tipo configurado, n�o � necess�rio informar o tipo de valor."
		M->FJS_TPVAL := ""
EndCase

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �Jair Ribeiro			� Data �29/11/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados    	  ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetua							  ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina :=	{{OemToAnsi(STR0003)	,"AxPesqui"			,0,1,0,.F.},;	//"Pesquisar"
					{ OemToAnsi(STR0004)	,"Fin025Dlg"		,0,2,0,nil},;	//"Visualizar"
					{ OemToAnsi(STR0005)	,"Fin025Dlg"		,0,3,0,nil},;	//"Incluir"
					{ OemToAnsi(STR0006)	,"Fin025Dlg"		,0,4,0,nil},;	//"Alterar"
					{ OemToAnsi(STR0007)	,"Fin025Dlg"		,0,5,0,nil},;	//"Excluir"
					{ OemToAnsi(STR0009)	,"Fin025TRec"		,0,2,0,.F.}}
Return aRotina

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fin025Del � Autor � Totvs                 � Data � 24/07/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a exlusao                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo do tipo de movimento                          ���
���          �ExpL2: Exibe help                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A360CanDel()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA025                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Fin025Del(cCodigo,lHelp)

Local aArea     := GetArea()
Local aAreaFJS  := FJS->(GetArea())	
Local cNomArq   := ""
Local lCanDel   := .T.          

#IFDEF TOP           
	Local cQuery    := ""
	Local lQuery    := .F.
#ENDIF

DEFAULT lHelp   := .T.

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������

dbSelectArea("FJS")
If lCanDel

	#IFDEF TOP
	
			//���������������������������������������������������������Ŀ
			//�Verifica Ordens de Pagamento                             �
			//�����������������������������������������������������������
			If lCanDel
				lQuery := .T.
	
				cQuery := "SELECT COUNT(*) RECSEK FROM "
				cQuery += RetSqlName("SEK") + " SEK "
				cQuery += " WHERE "                                    
				cQuery += "EK_FILIAL = '"+xFilial("SEK")+"' AND "
				cQuery += "EK_MODPAGO = '" + cCodigo + "' AND "
				cQuery += "SEK.D_E_L_E_T_ = ' ' "

				cQuery := ChangeQuery(cQuery)
				
				If SELECT("TRBSEK")> 0
					("TRBSEK")->(dbCloseArea())
				Endif
			
				dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSEK",.F.,.F.)

				If TRBSEK->RECSEK > 0
					If lHelp
						MsgAlert(STR0020,"NODELETA")
					Endif	
					lCanDel := .F.
					Return(lCanDel)
				Endif							

				dbCloseArea()
				dbSelectArea("SEK")
			                     
			Endif                           

		//���������������������������������������������������������Ŀ
		//�Verifica Cobrancas Diversas                              �
		//�����������������������������������������������������������
		
		If TcSrvType() <> "AS/400"
	
			lQuery := .T.
	
			cQuery := "SELECT COUNT(*) RECSEL FROM "
			cQuery += RetSqlName("SEL") + " SEL "
			cQuery += " WHERE "                                    
			cQuery += "EL_FILIAL = '"+xFilial("SEL")+"' AND "
			cQuery += "EL_TIPO = '" + cCodigo + "' AND "
			cQuery += "SEL.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			
			If SELECT("TRBSEL")> 0
				("TRBSEL")->(dbCloseArea())
			Endif
			
			dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSEL",.F.,.F.)

			If TRBSEL->RECSEL > 0
				If lHelp
					Alert(STR0020,"NODELETA")
				Endif	
				lCanDel := .F.
				Return(lCanDel)
			Endif							

			dbCloseArea()
			dbSelectArea("SEL")
			
	 #IFDEF TOP
    	Endif
	#ENDIF
			
	#ENDIF	   
EndIf		


Return(lCanDel)


