#INCLUDE "CNTA080.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CNTA080  � Autor � Marcelo Custodio      � Data �23.11.2005���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Manutencao do historico de Indices                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CNTA080()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA080                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CNTA080()
Private cCadastro := STR0001 //Historico de Indices
      
PRIVATE aRotina := 	MenuDef()
	  	 		                               
mBrowse(6,1,22,75,"CN7")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN080DEL � Autor � Marcelo Custodio      � Data �23.11.2005���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Exclusao do motivo de paralisacao			              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN080DEL()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN080DEL(cAlias,nReg,nOpc)	
	Local lRet := .T.
	If (lRet := VldIndUsad())
		AxDeleta( cAlias,nReg,nOpc )
	EndIf
Return lRet
                                     
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN080WData � Autor � Marcelo Custodio      � Data �24.11.2005���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao se o indice e diario                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN080WData()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA080                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function CN080WData()
          
If(CN6->CN6_CODIGO != M->CN7_CODIGO)//Verifica se o arquivo CN6 esta posicionado
	CN6->( dbSetOrder(1) )
	CN6->( dbSeek(xFilial("CN6")+M->CN7_CODIGO) )//Posiciona o arquivo     
EndIf

Return (CN6->CN6_TIPO = "1") //Verifica se o indice e diario
            

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN080WComp � Autor � Marcelo Custodio      � Data �24.11.2005���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Verifica se o indice e mensal                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN080WComp()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA080                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function CN080WComp()
          
If(CN6->CN6_CODIGO != M->CN7_CODIGO)//Verifica se o arquivo CN6 esta posicionado
	CN6->( dbSetOrder(1) )
	CN6->( dbSeek(xFilial("CN6")+M->CN7_CODIGO) )//Posiciona o arquivo       
EndIf

Return (CN6->CN6_TIPO = "2")//Verifica se o indice e mensal

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN080DESC� Autor � Marcos V. Ferreira    � Data �02.03.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega a descricao do campo CN7_DESCRI                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN080DESC()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN080DESC()
Local cCampo	:= AllTrim(ReadVar())
Local aAreaAnt	:= GetArea()
Local aAreaCN6  := CN6->(GetArea())
Local lRet 		:= .F.

dbSelectArea("CN6")
dbSetOrder(1)
If cCampo == "M->CN7_CODIGO" 
	If dbSeek(xFilial("CN6")+&cCampo)
		M->CN7_DESCRI := CN6->CN6_DESCRI
		lRet := .T.
	EndIf	
EndIf

RestArea(aAreaCN6)
RestArea(aAreaAnt)
Return lRet 

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �18/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
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
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()     
PRIVATE aRotina	:= 	{ 	{ STR0002, "AxPesqui"  		, 0, 1, 0, .F.},; 	//"Pesquisar"
			  			{ STR0003, "AxVisual"		, 0, 2, 0, nil},;				   //"Visualizar"
		  	 		 	{ STR0004, "AxInclui"		, 0, 3, 0, nil},;          	//"Incluir"
		  	 		 	{ STR0005, "AxAltera"		, 0, 4, 0, nil},;          	//"Alterar"
		  	 		 	{ STR0006, "CN080DEL"		, 0, 5, 0, nil},;          	//"Excluir"
		  	 		 	{ STR0007, "CNTA160" 		, 0, 6, 0, nil}} 	            //"Projetar"

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("CTA080MNU")
	ExecBlock("CTA080MNU",.F.,.F.)
EndIf
Return(aRotina)

/*/{Protheus.doc} VldIndUsad
	Verifica se o historico de indice atual foi utilizado em algum reajuste.
@author philipe.pompeu
@since 17/10/2019
@return lRet, se o registro atual pode ser deletado ou alterado
@type function
/*/
Static Function VldIndUsad()
	Local aAreas 	:= {CN6->(GetArea()),GetArea()}
	Local lRet		:= .T.	
	Local dDtDe		:= Date()
	Local dDtAte	:= Date()	
	Local cUmAlias:= GetNextAlias()
	
	CN6->(DbSetOrder(1))
	If(CN6->(DbSeek(xFilial('CN6') + CN7->CN7_CODIGO)))
		If(CN6->CN6_TIPO == '2')//Mensal
			dDtDe := FirstDate(CtoD('01/'+ CN7->CN7_COMPET)) 
			dDtAte:= LastDate(dDtDe)
		Else//Diario
			dDtDe := CN7->CN7_DATA
			dDtAte:= CN7->CN7_DATA
		EndIf
	
		BeginSQL Alias cUmAlias
			COLUMN DTREAJ as DATE
			
			SELECT CN9_DTREAJ AS DTREAJ FROM %Table:CN9% CN9
			WHERE CN9_FILIAL = %xFilial:CN9% AND CN9.%NotDel% AND CN9_INDICE = %Exp:CN7->CN7_CODIGO%
			UNION
			SELECT CNA_DTREAJ AS DTREAJ FROM %Table:CNA% CNA
			WHERE CNA_FILIAL = %xFilial:CNA% AND CNA.%NotDel% AND CNA_INDICE = %Exp:CN7->CN7_CODIGO%
			UNION
			SELECT CNB_DTREAJ AS DTREAJ FROM %Table:CNB% CNB
			WHERE CNB_FILIAL = %xFilial:CNB% AND CNB.%NotDel% AND CNB_INDICE = %Exp:CN7->CN7_CODIGO%
			
		EndSQL
		
		While ((cUmAlias)->(!Eof()))
			If((cUmAlias)->( DTREAJ >=  dDtDe .And. DTREAJ <= dDtAte))
				lRet := .F.
				Help( " ", 1, "CNTA080_03" )
				Exit			
			EndIf	
			(cUmAlias)->(dbSkip())
		EndDo
		(cUmAlias)->(DbCloseArea())		
	EndIf	
	aEval(aAreas, {|x|RestArea(x), aSize(x,0)})
Return lRet