#INCLUDE "PCOA130.ch"
#Include "Protheus.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA130  � AUTOR � Paulo Carnelossi      � DATA � 25/10/2004 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de Cadastro de Acessos aos Centros de Custos        ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA130                                                      ���
���_DESCRI_  � Programa de Cadastro de Acessos aos Centros de Custos (PCO)  ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA130(2) - Executa a chamada da funcao de visua-  ���
���          �                       zacao da rotina.                       ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOA130(nCallOpcx)

Private cCadastro	:= STR0001 //"Cadastro de Centros Or�ament�rios"
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil .And. ( nCallOpcx == 3 .OR. nCallOpcx == 4 )
	    If nCallOpcx == 3
	       Inclui := .T.
	    Else
	       Inclui := .F.
	    EndIf   
		PCOA130DLG("AKX",AKX->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AKX")
	EndIf
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA130DLG�Autor  �Paulo Carnelossi    � Data �  25/10/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �funcao para inclusao ou alteracao de acesso aos centros de  ���
���          �de custos (feito desta forma em razao validacao botao OK)   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA130DLG(cAlias,nReg,nOpcx)
If nOpcx == 3
	AxInclui(cAlias,nReg,nOpcx,/*aAcho*/,/*cFunc*/,/*aCpos*/,"PCOA130CC()"/*cTudoOk*/,/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
EndIf
If nOpcx == 4
    AxAltera(cAlias,nReg,nOpcx,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"PCOA130CC()"/*cTudoOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)	
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA130CC �Autor  �Paulo Carnelossi    � Data �  25/10/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �funcao para inclusao ou alteracao de acesso aos centros de  ���
���          �de custos (feito desta forma em razao validacao botao OK)   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA130CC(lAval, cUser, cCustoIni, cCustoFin, lInclui, nRecAKX)
Local aAreaAKX := AKX->(GetArea())
Local cAlias   := Alias()
Local lRet := .T.
Local aFaixaCC
Local nCtd := 0
Local nPriReg := 0
Local nTamCC := Len(AKX->AKX_CC_INI)
Local cQryCC := ""

Local cQryFinal := ""
Local cQryTmp  := GetNextAlias()
Local cTmpCC
Local lVazioTmp := .T.

DEFAULT lAval := .T.
DEFAULT cUser := M->AKX_USER
DEFAULT cCustoIni := M->AKX_CC_INI
DEFAULT cCustoFin := M->AKX_CC_FIN
DEFAULT lInclui   := Inclui
DEFAULT nRecAKX   := If(Inclui, 0, AKX->(Recno()))

If lAval .And. cCustoIni > cCustoFin
   HELP("  ",1,"PCOA1301") //Centro de custo inicial maior que final
   lRet := .F.
EndIf

If lRet
	//temporario criado no banco
	cTmpCC := CriaTrab( , .F.)
	MsErase(cTmpCC)
	MsCreate(cTmpCC,{{ "CTT_CUSTO", "C", Len(CTT->CTT_CUSTO), 0 }}, "TOPCONN")
	Sleep(1000)
	dbUseArea(.T., "TOPCONN",cTmpCC,cTmpCC/*cAlias*/,.T.,.F.)

	// Cria o indice temporario
	IndRegua(cTmpCC/*cAlias*/,cTmpCC,"CTT_CUSTO",,)

	dbSelectArea("AKX")
	dbSetOrder(1)
	aFaixaCC := {}
	If dbSeek(xFilial("AKX")+cUser)
		While ! Eof() .And. AKX_FILIAL == xFilial("AKX") .And. AKX_USER == cUser
		    If lInclui .OR. (!Inclui .And. Recno() <> nRecAKX)
				aAdd(aFaixaCC, {AKX_CC_INI, AKX_CC_FIN})
		    EndIf
			dbSkip()
		End
	EndIf
		
	If Len(aFaixaCC) > 0
		//1o. avalia se todos os elementos s�o do tipo caracter
		For nCtd := 1 TO Len(aFaixaCC)
		    aFaixaCC[nCtd][1] := PadR(Alltrim(aFaixaCC[nCtd][1]),nTamCC)  //inicio 
	    	aFaixaCC[nCtd][2] := PadR(Alltrim(aFaixaCC[nCtd][2]),nTamCC)  //final
	
			//avalia se todos os elementos sao numericos
			If 	Valtype(aFaixaCC[nCtd][1]) != "C" .OR. ;     //inicio
				Valtype(aFaixaCC[nCtd][2]) != "C"             //final
		    	HELP("  ",1,"PCOA1302") //Erro: Array enviado contem elemento nao caracter!
		   	    lRet := .F.
		    	EXIT
			EndIf
		Next
		
		If lRet
			//Cenario Atual ja incluido no cadastro
			//Usuario Faixa Inicial CC     Faixa Final CC
			//X       01                   03
			//X       10                   20
			//Tentando Incluir os centros de custo na faixa de 04 a 09
			//X       04                  09
			//primeiro contamos quantos CC tem na faixa de 04-09 (C1)
			//depois contamos quantos CC tem na faixa de 04-09 que nao estao cadastrados (C2)
			//entao fazemos comparacao se quantidade de centro de Custo e para permitir cadastros (C1) === (C2)
			//se for diferente entao � porque ja existe alguma faixa com cadastro destes centros de custos
		
			//monta a query para retornar todos os centros de custos constantes no array aFaixaCC
			For nCtd := 1 TO Len(aFaixaCC)
				cQryCC := " SELECT CTT_CUSTO FROM " + RetSqlName("CTT")
				cQryCC += " WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
				cQryCC += " AND CTT_CUSTO BETWEEN '" + aFaixaCC[nCtd][1] + "' AND '" + aFaixaCC[nCtd][2] + "' "
				cQryCC += " AND D_E_L_E_T_ = ' ' "				
				cQryCC := ChangeQuery(cQryCC)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryCC), cQryTmp, .F., .T.)
				dbSelectArea(cQryTmp)
    	        dbGoTop()
    			//alimenta o temporario criado no banco pois quando usuario tinha muito acesso estourava o tamanho da query	        
    	        While ! Eof()
    	        
    	        	dbSelectArea(cTmpCC)  //temporario criado no banco
    	        	Reclock(cTmpCC, .T.)
                    (cTmpCC)->CTT_CUSTO := (cQryTmp)->CTT_CUSTO
    	        	MsUnlock()
    	        	lVazioTmp := .F.
    	        
    	        	dbSelectArea(cQryTmp)
    	        	dbSkip()
    	        EndDo
				dbSelectArea(cQryTmp)
    	        dbCloseArea()
	
			Next
			
        	dbSelectArea(cTmpCC)  //temporario criado no banco
			dbCloseArea()

			//Monta a query final
		
            //monta a query para retornar se encontrou cc inicial/final informado se existe no array aFaixaCC
			cQryFinal := " SELECT COUNT(CTT_CUSTO) NCOUNTCTT FROM " + RetSqlName("CTT")
			cQryFinal += "        WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
			cQryFinal += "          AND CTT_CUSTO BETWEEN '" + cCustoIni + "' AND '" + cCustoFin + "' "
			cQryFinal += "          AND D_E_L_E_T_ = ' ' "
			If ! lVazioTmp
				//faz union com arquivo de centro de custo e temporario contendo as faixas de centro de custo ja inclusas
				cQryFinal += " UNION ALL "
	            //somente retorna os centros de custo se nao existe no array aFaixaCC
	            cQryFinal += " SELECT COUNT(CTT_CUSTO) NCOUNTCTT FROM " + RetSqlName("CTT")
				cQryFinal += "         WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
				cQryFinal += "           AND CTT_CUSTO BETWEEN '" + cCustoIni + "' AND '" + cCustoFin + "' "
				cQryFinal += "           AND D_E_L_E_T_ = ' ' "
				cQryFinal += "           AND CTT_CUSTO NOT IN ( SELECT CTT_CUSTO FROM " + cTmpCC + " ) "
			EndIf
			cQryFinal := ChangeQuery(cQryFinal)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryFinal), cQryTmp, .F., .T.)
			dbSelectArea(cQryTmp)
            dbGoTop()
			
			//avalia retorno da query no primeiro registro
            lRet := ( (nPriReg := (cQryTmp)->NCOUNTCTT) > 0 )
			//avalia segundo registro se primeiro retornou algum contador de centro de custo            
			If lRet .And. ! lVazioTmp
				dbSelectArea(cQryTmp)
            	dbSkip() //vai para segundo registro
				lRet := ( (cQryTmp)->NCOUNTCTT == nPriReg )
			Else
				HELP("  ",1,"PCOA1303") //Faixa de centro de Custo ja existente nao esta integra.Verificar!
			EndIf						
			            
			dbSelectArea(cQryTmp)
            dbCloseArea()
            //apaga arquivo temporario criado
            MsErase(cTmpCC)
            
            If ! lRet
				HELP("  ",1,"PCOA1304") //Faixa de centro de Custo ja existente, portanto nao pode ser incluida!
            EndIf
            
	    EndIf
	    
	EndIf
		
EndIf
	
RestArea(aAreaAKX)
dbSelectArea(cAlias)

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AvFaixaCC �Autor  �Paulo Carnelossi    � Data �  25/10/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Avalia se elemento 1 ou 2 podem ser inseridos na Tabela de  ���
���          �Acessos ao Centro de Custo                                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AvFaixaCC(lAval,cNewElem1, cNewElem2, aElemExistente)
Local cInicio, cFim, nCtd, cAnterior := Space(Len(AKX->AKX_CC_INI))
Local lRet := .T.
Local nTamCC := Len(cNewElem1)

cNewElem1 := PadL(Alltrim(cNewElem1),nTamCC)
cNewElem2 := PadL(Alltrim(cNewElem2),nTamCC)

For nCtd := 1 TO Len(aElemExistente)
    aElemExistente[nCtd][1] := PadL(Alltrim(aElemExistente[nCtd][1]),nTamCC)
    aElemExistente[nCtd][2] := PadL(Alltrim(aElemExistente[nCtd][2]),nTamCC)
Next

If lAval .And. cNewElem1 > cNewElem2
   HELP("  ",1,"PCOA1301") //Centro de custo inicial maior que final
   lRet := .F.
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		//avalia se todos os elementos sao numericos
		If Valtype(aElemExistente[nCtd][1]) != "C" .OR. ;
	    	Valtype(aElemExistente[nCtd][2]) != "C"
	    	HELP("  ",1,"PCOA1302") //Erro: Array enviado contem elemento nao caracter!
	   	    lRet := .F.
	    	EXIT
	   EndIf
	   // avalia se elemento inicial e maior que anterior e neste caso
	   // atribui a cAnterior o segundo elemento
	   // senao esta errado - avisa usuario e sai
	   If aElemExistente[nCtd][1] > cAnterior
			cAnterior := aElemExistente[nCtd][2]
		Else
			HELP("  ",1,"PCOA1303") //Faixa de centro de Custo ja existente nao esta integra.Verificar!
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
				HELP("  ",1,"PCOA1304") //Faixa de centro de Custo ja existente, portanto nao pode ser incluida!
				lRet := .F.
				EXIT
			EndIf	
		Else	
			//se elemento 1 for menor que inicio avalia elemento 2
			If cNewElem2 >= cInicio
				HELP("  ",1,"PCOA1304") //Faixa de centro de Custo ja existente, portanto nao pode ser incluida!
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
							{ STR0004, 		"pcoa130Dlg" , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"pcoa130Dlg" , 0 , 4},; //"Alterar"
							{ STR0006, 		"AxDeleta" , 0 , 5}} //"Excluir"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no Browse                                   �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA1301" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Centros Orcamentarios                                            �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA1301                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA1301", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf          
EndIf
Return(aRotina)	