#INCLUDE "PCOA150.ch"
#Include "Protheus.ch"

/*/
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA150  � AUTOR � Paulo Carnelossi      � DATA � 26/10/2004 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de Cadastro de Acessos a Classe de Valor            ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA150                                                      ���
���_DESCRI_  � Programa de Cadastro de Acessos a Classe de Valor  (PCO)     ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA150(2) - Executa a chamada da funcao de visua-  ���
���          �                       zacao da rotina.                       ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOA150(nCallOpcx)

Private cCadastro	:= STR0001 //"Cadastro de Acesso de Usuarios a Classe de Valor"
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil .And. ( nCallOpcx == 3 .OR. nCallOpcx == 4 )
	    If nCallOpcx == 3
	       Inclui := .T.
	    Else
	       Inclui := .F.
	    EndIf   
		PCOA150DLG("AKV",AKV->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AKV")
	EndIf
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA150DLG�Autor  �Paulo Carnelossi    � Data �  26/10/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �funcao para inclusao ou alteracao de acesso a classe valor  ���
���          �(feito desta forma em razao validacao botao OK)             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA150DLG(cAlias,nReg,nOpcx)
If nOpcx == 3
	AxInclui(cAlias,nReg,nOpcx,/*aAcho*/,/*cFunc*/,/*aCpos*/,"PCOA150CV()"/*cTudoOk*/,/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
EndIf
If nOpcx == 4
    AxAltera(cAlias,nReg,nOpcx,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"PCOA150CV()"/*cTudoOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)	
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA150CV �Autor  �Paulo Carnelossi    � Data �  26/10/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �funcao para inclusao ou alteracao de acesso de usuario as   ���
���          �classes de valor                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA150CV(lAval, cUser, cClVlrIni, cClVlrFin, lInclui, nRecAKV)
Local aAreaAKV := AKV->(GetArea())
Local cAlias   := Alias()
Local lRet := .T.
Local aFaixaCV

DEFAULT lAval := .T.
DEFAULT cUser := M->AKV_USER
DEFAULT cClVlrIni := M->AKV_CV_INI
DEFAULT cClVlrFin := M->AKV_CV_FIN
DEFAULT lInclui   := Inclui
DEFAULT nRecAKV   := If(Inclui, 0, AKV->(Recno()))

dbSelectArea("AKV")
dbSetOrder(1)
aFaixaCV := {}
If AKV->(dbSeek(xFilial("AKV")+cUser))
	While !AKV->(Eof()) .And. AKV->(AKV_FILIAL+AKV_USER) == xFilial("AKV")+cUser
	    If lInclui .OR. (!Inclui .And. AKV->(Recno()) <> nRecAKV)
			aAdd(aFaixaCV, {AKV->AKV_CV_INI, AKV->AKV_CV_FIN})
	    EndIf
		AKV->(dbSkip())
	EndDo
	
	If Len(aFaixaCV) > 0
		lRet := AvFaixaCV(lAval, cClVlrIni, cClVlrFin, aFaixaCV)
	EndIf
	
EndIf
	
RestArea(aAreaAKV)
dbSelectArea(cAlias)

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AvFaixaCV �Autor  �Paulo Carnelossi    � Data �  26/10/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Avalia se elemento 1 ou 2 podem ser inseridos na Tabela de  ���
���          �Acessos ao Item Contabil                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AvFaixaCV(lAval,cNewElem1, cNewElem2, aElemExistente)
Local cInicio, cFim, nCtd, cAnterior := Space(Len(AKV->AKV_CV_INI))
Local lRet := .T.
Local nTamCC := Len(cNewElem1)

cNewElem1 := PadL(Alltrim(cNewElem1),nTamCC)
cNewElem2 := PadL(Alltrim(cNewElem2),nTamCC)

For nCtd := 1 TO Len(aElemExistente)
    aElemExistente[nCtd][1] := PadL(Alltrim(aElemExistente[nCtd][1]),nTamCC)
    aElemExistente[nCtd][2] := PadL(Alltrim(aElemExistente[nCtd][2]),nTamCC)
Next

If lAval .And. cNewElem1 > cNewElem2
	HELP("  ",1,"PCOA1501") //Classe de Valor inicial maior que final!
	lRet := .F.
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		//avalia se todos os elementos sao numericos
		If Valtype(aElemExistente[nCtd][1]) != "C" .OR. ;
	    	Valtype(aElemExistente[nCtd][2]) != "C"
			HELP("  ",1,"PCOA1502") //Erro: Lista de classe de valor enviado contem elemento nao caracter!
			lRet := .F.
	    	EXIT
	   EndIf
	   // avalia se elemento inicial e maior que anterior e neste caso
	   // atribui a cAnterior o segundo elemento
	   // senao esta errado - avisa usuario e sai
	   If aElemExistente[nCtd][1] > cAnterior
			cAnterior := aElemExistente[nCtd][2]
		Else	
			HELP("  ",1,"PCOA1503") //Faixa de Classe de Valor ja existente nao esta integra.Verificar!
	    	lRet := .F.
	    	EXIT
		EndIf	
	Next
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		cInicio	:= aElemExistente[nCtd][1]
		cFim		:= aElemExistente[nCtd][2]
		
		If cNewElem1 > cInicio
		    //avalia elementos a Inserir
			If cNewElem1 <= cFim .OR. cNewElem2 <= cFim
				HELP("  ",1,"PCOA1504") //Faixa de Classe de Valor ja existente, portanto nao pode ser incluida!
				lRet := .F.
				EXIT
			EndIf	
		Else	
			//se elemento 1 for menor que inicio avalia elemento 2
			If cNewElem2 >= cInicio
				HELP("  ",1,"PCOA1504") //Faixa de Classe de Valor ja existente, portanto nao pode ser incluida!
				lRet := .F.
				EXIT
			EndIf	
		EndIf
	Next
EndIf

Return(lRet)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �10/12/06 ���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"AxVisual" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"pcoA150Dlg" , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"pcoA150Dlg" , 0 , 4},; //"Alterar"
							{ STR0006, 		"AxDeleta" , 0 , 5}} //"Excluir"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no Browse                                   �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA1501" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Centros Orcamentarios                                            �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA1501                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA1501", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf      
EndIf	
Return(aRotina)