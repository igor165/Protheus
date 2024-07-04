#INCLUDE "LOJA600.CH"
#INCLUDE "PROTHEUS.Ch"
                                                                                               
                                                                                           
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Loja600  � Autor � Fabiana Cristina      � Data �22/11/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Estorno de Vendas                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaLoja                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LOJA600()

Local cLock 		:= cUserName + cEstacao   //Controle de acesso da rotina
Local aCores 		:= Lj600DefLeg()  //Cores da MBrowse 
Local cCondicao     := ""             //Filtro da mBrowse
Local nPosL4Est     := SL4->(FieldPos("L4_ESTORN"))
Local nPosL1Sta     := SL1->(FieldPos("L1_STATUES"))
Local lIsMDI 		:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),SetMDIChild(0)) //Verifica se acessou via SIGAMDI

Private aQuery		:= {}             //Filtro da MBrowse
Private aRotina		:= MenuDef()      //Opcoes de execucao da rotina


//�����������������������������������������������������������������������Ŀ
//� Faz o controle via LockByName para evitar que um usu�rio acesse       �
//� 2 vezes uma rotina que use os perif�ricos de automa��o, evitando assim�
//� a concorr�ncia dos mesmos.                                            �
//�������������������������������������������������������������������������

If nPosL4Est = 0 .Or. nPosL1Sta = 0
	MsgStop(STR0012) //"Para utilizacao da rotina de estorno, faz-se necess�ria a criacao dos campos, L4_ESTORN e L1_STATUES contidos na FNC 000000225902010"
	Return Nil
EndIf

If lIsMDI .AND. !LockByName( cLock )
	Return Nil
EndIf

//������������������������������������������������������������������������Ŀ
//�Realiza a Filtragem                                                     �
//��������������������������������������������������������������������������
DbSelectArea("SL1")
DbSetOrder(1)

cCondicao := "(!Empty(L1_DOC) .OR. !Empty(L1_DOCPED)) .AND. ( !Empty(L1_SERIE) .Or. !Empty(L1_SERPED) ) .AND. L1_TIPO <> 'D' .AND. ( L1_TIPO == 'V' .or. L1_TIPO == 'P') .AND. L1_STORC <> 'E' .AND. Empty(L1_ORCRES) .AND. Empty(L1_PEDRES) "

Eval({|| FilBrowse("SL1",@aQuery,@cCondicao) })
//��������������������������������������������������������������Ŀ
//� Endere�a a fun��o de BROWSE									 �
//����������������������������������������������������������������
mBrowse(,,,,"SL1",,,,,, aCores )   

EndFilBrw("SL1",aQuery)   

//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados						     �
//����������������������������������������������������������������
msUnlockAll()
Return Nil   


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef	� Autor � Vendas Clientes       � Data �28/12/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 

Local cLabelOpcao   := STR0001  	// "Estornar"
Local aRotina	:= {}               //Opcoes da MBrowse

	aRotina := { 	{ STR0002     	, "AxPesqui"  , 0 , 1 , , .F. }, ;  //Pesquisar
				 	{ STR0003    	, "Lj600Estor"  , 0 , 2 , , .T. }, ;  //"Visualizar"
					{cLabelOpcao    , "Lj600Estor" , 0 , 4 , , .T. } }   //"Estornar"
	
AAdd(aRotina,{"Legenda","Lj600Leg",0,8 , , .T. })      //legenda
					
							
Return aRotina

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Lj600Estor� Autor � Fabiana Cristina      � Data �22/11/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Execu��o do Estorno das Vendas                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � lj140Exc(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
���          � ExpL1 = Origem remota                                      ���
���          � ExpC2 = Numero de origem do or�amento                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj600Estor(cAlias, nReg, nOpcx, lRemote , cDoc , cSerie , cNewCli , cNewLoja )   

Local oEstorno := nil     //Objeto de Estorno
Local cCliOri  := Space(TamSX3("A1_COD")[1])  //Cliente original da venda.
Local cLojaOri := Space(TamSx3("A1_LOJA")[1]) //Loja original da venda.
Local aDocDev  		:= {}    
Local lRestInclu	:= Iif(Type("INCLUI")<>"U",INCLUI,.T.)
Local lRestAlter    := Iif(Type("ALTERA")<>"U",ALTERA,.F.) 
Local lRet			:= .T.  

If nOpcx = 3
	nOpcx := nOpcx + 1
EndIf 

Default cAlias 		:= ""
Default nReg 		:= 0
Default nOpcx 		:= 0 
Default lRemote 	:= .F. //-- Variavel que identifica a origem da chamada da funcao  
Default cDoc	    := ""  
Default cSerie		:= ""
Default cNewCli  	:= Space(TamSX3("A1_COD")[1])  //-- Cliente para o estorno.
Default cNewLoja 	:= Space(TamSx3("A1_LOJA")[1]) //-- Loja para o estorno. 

//-- Se chamada for remota, posiciona no registro 
If lRemote
	SL1->( dbSetOrder(2) ) 
	If !Empty(cDoc) .And. SL1->( MsSeek( xFilial("SL1") + cSerie + cDoc ) ) 
    	nReg := Recno()  
	Else    
		lRet := .F.  	
	EndIf
EndIf


If lRet  

	cNewSerie := SerieNfId("MBZ",2,"MBZ_SERIE",dDataBase,LjEspecieNF(),LJGetStation("SERIE"))

	oEstorno := ljClEstVen():New(cNewSerie, xNumCaixa(), LJGetStation("PDV"), dDataBase,0, .T. , Iif(!lRemote,aQuery,{}) ) 

	If lRemote 
		oEstorno:lJob := .T.    
		oEstorno:BuscaOrcamento(SL1->L1_DOC , SL1->L1_SERIE) //-- Carrega as propriedades do Orcamento
	Else
		oEstorno:GetOrcamento()  //-- Carrega as propriedades do Orcamento  	
	EndIf

	cCliOri    := oEstorno:cOrc_Cli  
	cLojaOri   := oEstorno:cOrc_Loja 
    
	lRet := .F.
 
	If oEstorno:ValidaOrcamento(nOpcx,lRemote)  //Valida se o or�amento pode ser estornado				
		If Lj600VlEst(nOpcx) //Valida a esta��o da retaguarda 			 				
 		
	 		If lRemote .Or. oEstorno:ConfirmaOrcamento(nOpcx)   
 			
	 		    If Alltrim(oEstorno:cOrc_Cli) <> Alltrim(cCliOri) //Houve troca de cliente e loja. 
		 			cNewCli  := oEstorno:cOrc_Cli
		 			cNewLoja := oEstorno:cOrc_Loja
		 			oEstorno:cOrc_Cli  := cCliOri
		 			oEstorno:cOrc_Loja := cLojaOri
		 		EndIf 
			
				If oEstorno:RealizaEstorno( cNewCli , cNewLoja, @aDocDev , lRemote )

                    //Efetua o cancelamento da fideliza��o
                    If ExistFunc("LjxRaasInt") .And. LjxRaasInt() .And. SL1->L1_FIDCORE
                        Lj7FidCanc(SL1->L1_FILIAL + SL1->L1_NUM, SL1->L1_ESTACAO)
                    EndIf
						     
				    //-- Central de PDV nao realiza venda e se a origem da chamada da funcao for remota n�o deve abrir o Loja701	
					If !lRemote .And. MsgYesNo("Venda Assistida","Deseja realizar nova venda?") 
			            
						INCLUI := .T.
						ALTERA := .F. 
						//������������������������������������������������������������Ŀ
						//�Limpa o filtro ativo criado na tabela SD2                   �
						//�antes de executar a rotina de Atendimento da Venda Assistida�
						//��������������������������������������������������������������
						DbSelectArea("SD2")
						RetIndex("SD2")
						DbClearFilter()
			           	
			           	SaveInter()
			           	
			           	//-- Venda Assistida	
						Loja701(  .T.  ,   3   ,  Iif(!Empty(cNewCli),cNewCli,cCliOri)  ,  Iif(!Empty(cNewLoja),cNewLoja,cLojaOri)  ,  aDocDev  )  
								  
						RestInter()
						
						//-- Restaura variaveis INLCUI e ALTERA
						INCLUI := lRestInclu
						ALTERA := lRestAlter
						
					EndIf
					
					lRet := .T.
										
				EndIf
								
			EndIf		
	 	EndIf      
	EndIf
EndIf       

//-- Se a origem for remota, nao � necessario filtrar o browse
If !lRemote
	aQuery := oEstorno:aQuery //Filtro do SL1
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj600DefLg�Autor  �Fabiana Cristina    � Data �  22/11/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Define as cores das Legendas                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA600                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Lj600DefLeg()
Local aCores := {}


Aadd(aCores,	{'!Empty(L1_DOC) .AND. !Empty(L1_SERIE) .AND. L1_STATUS <> "D" .AND. (FieldPos("L1_STATUES") = 0 .Or. Empty(L1_STATUES))'													,"BR_VERMELHO"	})	//"Vendas efetuadas"
Aadd(aCores,	{'Empty(L1_DOC) .AND. L1_TIPO=="P"       .AND. !Empty(L1_DOCPED)   .AND. L1_STATUS<>"D" .AND. (FieldPos("L1_STATUES") = 0 .Or. Empty(L1_STATUES))'  						,"BR_AZUL"		})//"Pedidos encerrados"  
Aadd(aCores,	{'L1_STATUS="D" .AND. (FieldPos("L1_STATUES") = 0 .Or. Empty(L1_STATUES)) '																							   		,"BR_MARROM"	}) 	  //"Devolu��es pendentes"
Aadd(aCores,	{'FieldPos("L1_STATUES")> 0 .and. !Empty(L1_STATUES)'														   																,"BPMSEDT1"	}) 	//"Vendas Estornadas"									


Return aCores

/*/
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � Lj600Leg  � Autor � Fabiana Cristina      � Data �23/11/2010���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de legenda da tela								   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj600Leg()		                                           ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Lj600Leg()


Local aLegenda := { {"BR_VERMELHO",	STR0004},; //"Vendas efetuadas"
					{"BR_AZUL",		STR0005},; //"Pedidos encerrados"
					{"BR_MARROM",	STR0006},;    // 	"Devolu��es pendentes"
					{"BPMSEDT1",	STR0013}} //" Vendas estornadas"


BrwLegenda(STR0007, STR0008, aLegenda) //"Vendas"###"Legenda"

Return .T.    

/*/
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � Lj600VlEs � Autor � Fabiana Cristina      � Data �24/11/2010���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de valida��o da Esta��o na retagurada  			   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj600VlEs()		                                           ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function Lj600VlEst(nOpcx)
Local lValido := .T.
Local cRet       	:= Space(10)						// Retorno utilizado status do cupom
Local nRet       	:= 0								// Retorno do cupom

If nOpcx = 4
	If lFiscal
		nRet := IFStatus( nHdlECF, '5', @cRet )				// Verifica se o cupom est� aberto
		If nRet == 7
			MsgInfo( STR0009 )								//'Cupom nao foi finalizado'
			lValido := .F.
		EndIf
		
	EndIf
		
	//��������������������������������Ŀ
	//� Verifica se Caixa esta Aberto  �
	//����������������������������������
	If lValido .and. lFiscal .AND. !ljCxAberto()
		lValido := .F.
	EndIf 
EndIf

Return lValido 

/*/
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � Lj600VlPr � Autor � Fabiana Cristina      � Data �30/11/2010���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Validacao da linha do Browse de Pagamentos 	   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj600VlPr()		                                           ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function Lj600VlPr(lTEFPag, aLinhasPg)
Local lRetorno := .F.
Local nPosPorte := aScan(aHeader, {|c| AllTrim(c[2]) == "PORTE"})
Local nPosForma := aScan(aHeader, {|c| AllTrim(c[2]) == "L4_FORMA"})   
Local nPosEst := aScan(aHeader, {|c| AllTrim(c[2]) == "L4lEstorn"}) 

If !lTEfPag .and. ( AllTrim(aCols[n, nPosForma]) $ "CD/CC")

	aLinhasPg[n, nPosEst] := aCols[n, nPosEst]
	lRetorno := Empty(aCols[n, nPosPorte]) 
	If !lRetorno 
   		MsgAlert(STR0010) 
	EndIf
Else
	
	If ( (AllTrim(aCols[n, nPosForma]) $ "CD/CC") .Or.  IsMoney(aCols[n, nPosForma]) )
		lRetorno := Empty(aCols[n, nPosPorte])
		If !lRetorno 
			MsgAlert(STR0010) 
		EndIf
	Else
		lRetorno := !Empty(aCols[n, nPosPorte])
		If !lRetorno 
			MsgAlert(STR0011) 
		EndIf	
	    aLinhasPg[n, nPosPorte] := aCols[n, nPosPorte] 
	    
	EndIf 
EndIf
Return lRetorno

