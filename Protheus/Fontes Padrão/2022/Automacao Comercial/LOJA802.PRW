#INCLUDE "LOJA802.CH"         
#INCLUDE "PROTHEUS.CH"

Static bFiltraBrw := {} // Filtro do Browse

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �LOJA802   � Autor � Venda Clientes        � Data �26/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Redirecionamento logistico                           	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � LOJA802()									              ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil        									              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGALOJA                          						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA802()
	
Local aCores := {	{"Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE' },;		//Pedido em Aberto
					{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)" ,'DISABLE'},;		//Pedido 		
					{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)",'BR_AMARELO'},;   	//Pedido em Aberto
					{ "C5_BLQ == '1'",'BR_AZUL'},;													//Pedido Bloquedo por regra
					{ "C5_BLQ == '2'",'BR_LARANJA'}}												//Pedido Bloquedo por verba

Local cFiltra 	:= "C5_NOTA == '"+'         '+"'" 	// Filto MBrowse
Local cAlias 	:= "SC5"							// Alias de Pedido de Venda
Local aIndexSC5 := {}								// Index Pedido de Venda

// Campo verificador se est� sendo chamado pelo Robo
Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

If GetRpoRelease("R5")
	bFiltraBrw := { || FilBrowse(cAlias,@aIndexSC5,@cFiltra) }
	Private cCadastro 	:= STR0001   // "Redirecionamento Log�stico (Pedido de Venda)"
	Private aRotina 	:= {	{STR0002,"AxPesqui"	,0,1} ,;   			//"Pesquisa"
				         		{STR0003,"LJ802Tr"	,0,2} ,; 			//"Red. Log�stico"
				         		{STR0004,"Lj802Leg",	0,3,0 ,.F.}}   	//"Legenda"
	Eval(bFiltraBrw)
	DbSelectArea("SC5")
	DbSetOrder(1)
	// Se a rotina for chamado pelo Robo nao exibir o mBrowse
	If !lAutomato
		MBrowse( 6,1,22,75,'SC5',Nil,Nil,Nil,Nil,Nil,aCores)
	EndIf
	EndFilBrw(cAlias,aIndexSC5)
Else
	Alert(STR0022) //Op��o indisponivel
EndIf


Return()     
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �LjPrepar  � Autor � Venda Clientes        � Data �26/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama Redirecionamento logistico  com LJMSGRUN()           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � LJ802Tr()									              ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil        									              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGALOJA                          						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJ802Tr()
	LJMsgRun( STR0006, STR0005, {|| LJ8TrPed() } ) // "Aguarde." "Aguarde, Realizando Redirecionamento Lg�tico..."
Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �LJ8TrPed  � Autor � Venda Clientes        � Data �26/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicia e finaliza um Redirecionamento                	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � LJ8TrPed()						              			  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil        									              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGALOJA                          						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJ8TrPed()

Local aArea      	:= GetArea() 	// Backup Area Alias
Local nVlrDep		:= 0			// Valor para passar como referencia 			
Local cFilBk		:= cFilAnt		// Backup da Falial
Local cFilDes		:= ""			// Filial de Destino
Local lContinua		:= .T.			// Informa se continua a transa��o
Local cNuNovPed		:= ""			// Guarda numero do novo pedido do ExecAuto8/9
Local cMsg			:= ""			// Mensagem de errp
Local aMem 			:= {}			// Mensagem de errp
Local cMotivo		:= ""          	// Motivo do Redirecionamento
Local aRetFil		:= {}			// Filial

//������������������������Ŀ
//�Descri��o do Array      �
//�                        �
//�aMem[1] FILIAL ORIGEM   �
//�aMem[2] FILIAL DESTINO  �
//�aMem[3] PEDIDO ORIGEM   �
//�aMem[4] PEDIDO DESTINO  �
//�aMem[5] ORCAMENTO ORIGEM�
//�aMem[6] DATA            �
//�aMem[7] MOTIVO          �
//��������������������������
aMem := Array(7)

aRetFil := Lj8Filtr()

If Len(aRetFil) > 0
	cFilDes := aRetFil[1] 	
	cMotivo := aRetFil[2]	
	
	aMem[1] := cFilAnt
	aMem[2] := cFilDes
	aMem[3] := SC5->C5_NUM
	aMem[5] := SC5->C5_ORCRES
	//�����������������������������������������������������������������Ŀ
	//�Troca numero da filial, gera pedido e recupera o numero do pedido�
	//�������������������������������������������������������������������
	If !Empty(cFilDes )
		cFilAnt := cFilDes 
	EndIF
	cNuNovPed := Lj802Ped(cFilBk, aMem[3], 0)
	cFilAnt := cFilBk   
	RestArea(aArea)
	
	If Empty(cNuNovPed) 
		lContinua		:= .F.			
	 	cMsg := STR0007 + aRetFil[2] + "." // "N�o foi possivel criar Pedido de Venda na filial "
	Else
		aMem[4] := 	cNuNovPed
	EndIf
	
	//������������������������Ŀ
	//�Procura or�amento no SL1�
	//��������������������������
	aMem[6] := dDataBase
	aMem[7] := cMotivo
	
	If lContinua
		Begin Transaction
		    
		 	lContinua := .F.
			//�����������������Ŀ
			//�Estorna Libera��o�
			//�������������������
			DbSelectArea("SC9") 
			DbSetOrder(1)
			If DbSeek(xFilial("SC9")+SC5->C5_NUM)
				While  !Eof() .AND. SC9->C9_PEDIDO == SC5->C5_NUM
					aArea      := GetArea()
					a460Estorna()
			    	RestArea(aArea)
			    	DbSkip()
			    End
			EndIf
		
			//���������������Ŀ
			//�Elimina Residuo�
			//�����������������
			DbSelectArea("SC6") 
			DbSetOrder(1)
			If DbSeek(xFilial("SC6")+SC5->C5_NUM)
				While ( !Eof() .And. xFilial("SC6")==C6_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM)
					aArea      := GetArea()
					MaResDoFat(nil, .T., .F., @nVlrDep)
					MaLiberOk({ SC5->C5_NUM }, .T.)
					RestArea(aArea)
					DbSkip()
			    End
			EndIf
			lContinua := .T.
		End Transaction 	
	EndIf
	
	//�������������������������������������������������������Ŀ
	//�Grava dados do Pedido de Venda e reinicializa variaveis�
	//���������������������������������������������������������
	cFilAnt := cFilBk
	If lContinua 
	 	Lj8GrMem(aMem)
	EndIf
	Eval(bFiltraBrw)
EndIf
//���������������Ŀ
//�Restaura filial�
//�����������������
cFilAnt := cFilBk
Return()         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �LJ802Arr  � Autor � Venda Clientes        � Data �26/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera array com informacoes do SC5 E SC6 original     	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � LJ802Arr(Expx1,Expx2, Expx3,Expx4)						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Filial Original      							  ���
���          � ExpX2 - Pedido pesicionado       						  ���
���          � ExpX2 - Array sc5 como ref         						  ���
���          � ExpX2 - Array com os itens do sc5 						  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil        									              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGALOJA                          						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJ802Arr(cFilOri, cNumC5, aSc5, aItensPed)

Local aSc6 := {} // Array para gerar itens no aItensPed

Default cFilOri 	:= ""
Default cNumC5  	:= cNumC5
Default aSc5  		:= {}
Default aItensPed   := {}


DbSelectArea("SC5")
DbSetOrder(1)

If DbSeek(cFilOri+cNumC5)
	
	aSc5 := {}
	//���������������������Ŀ
	//�Gera array Tabela SC5�
	//�����������������������
	Aadd(aSc5,{ "C5_FILIAL",	xFilial()			,NIL })
	Aadd(aSc5,{ "C5_TIPO",		"N"					,NIL })
	Aadd(aSc5,{ "C5_CLIENTE",	SC5->C5_CLIENTE		,NIL })
	Aadd(aSc5,{ "C5_LOJACLI",	SC5->C5_LOJACLI		,NIL })
	Aadd(aSc5,{ "C5_CLIENT",	SC5->C5_CLIENT		,NIL })
	Aadd(aSc5,{ "C5_LOJAENT",	SC5->C5_LOJAENT		,NIL })
	Aadd(aSc5,{ "C5_TRANSP",	SC5->C5_TRANSP		,NIL })
	Aadd(aSc5,{ "C5_TIPOCLI",	SC5->C5_TIPOCLI		,NIL })
	Aadd(aSc5,{ "C5_EMISSAO",	SC5->C5_EMISSAO		,NIL })
	Aadd(aSc5,{ "C5_VEND1",		SC5->C5_VEND1		,NIL })
	Aadd(aSc5,{ "C5_CONDPAG",	SC5->C5_CONDPAG 	,NIL })
	Aadd(aSc5,{ "C5_ORCRES",	SC5->C5_ORCRES		,NIL })
	Aadd(aSc5,{ "C5_FRETE",		SC5->C5_FRETE		,NIL })
	Aadd(aSc5,{ "C5_SEGURO",	SC5->C5_SEGURO		,NIL })
	Aadd(aSc5,{ "C5_DESPESA",	SC5->C5_DESPESA		,NIL })
	Aadd(aSc5,{ "C5_TPFRETE",	SC5->C5_TPFRETE		,NIL })
	Aadd(aSc5,{ "C5_DESC1"	,	SC5->C5_DESC1		,NIL })
	Aadd(aSc5,{ "C5_LIBEROK",	SC5->C5_LIBEROK		,NIL })
		
	//���������������������Ŀ
	//�Gera array Tabela SC6�
	//�����������������������
	DbSelectArea("SC6")
	DbSetOrder(1)
	If DbSeek(cFilOri+cNumC5)
		While !Eof() .AND. SC6->C6_FILIAL == cFilOri	.AND. SC6->C6_NUM == cNumC5
			aSc6 := {}
			Aadd(aSc6,{ "C6_FILIAL",	xFilial()	   		,NIL })
			Aadd(aSc6,{ "C6_ITEM",		SC6->C6_ITEM 		,NIL })
			Aadd(aSc6,{ "C6_PRODUTO",	SC6->C6_PRODUTO 	,NIL })
			Aadd(aSc6,{ "C6_DESCRI",	SC6->C6_DESCRI 		,NIL })
			Aadd(aSc6,{ "C6_UM",		SC6->C6_UM 			,NIL })
			Aadd(aSc6,{ "C6_QTDVEN",	SC6->C6_QTDVEN 		,NIL })
			Aadd(aSc6,{ "C6_QTDLIB",	SC6->C6_QTDVEN		,NIL }) 
			Aadd(aSc6,{ "C6_PRCVEN",	SC6->C6_PRCVEN 		,NIL })
			Aadd(aSc6,{ "C6_VALOR",		SC6->C6_VALOR 		,NIL })
			Aadd(aSc6,{ "C6_TES",		SC6->C6_TES			,NIL })
			Aadd(aSc6,{ "C6_CF",		SC6->C6_CF 		 	,NIL })
			Aadd(aSc6,{ "C6_LOCAL",		SC6->C6_LOCAL 		,NIL })
			Aadd(aSc6,{ "C6_CLI",		SC6->C6_CLI 		,NIL })
			Aadd(aSc6,{ "C6_LOJA",		SC6->C6_LOJA  		,NIL })
			Aadd(aSc6,{ "C6_CLASFIS",	SC6->C6_CLASFIS 	,NIL })
			Aadd(aSc6,{ "C6_PRUNIT",	SC6->C6_PRUNIT 		,NIL })
			Aadd(aSc6,{ "C6_ENTREG",	SC6->C6_ENTREG 		,NIL })
			Aadd(aSc6,{ "C6_TURNO",		SC6->C6_TURNO 		,NIL })
		 	DbSkip()
			Aadd(aItensPed, aSc6)
		End
	EndIf
EndIf

Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Lj802Ped  � Autor � Venda Clientes        � Data �26/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera ExecAuto                           	  				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Lj802Ped(Expx1,Expx2)								      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Expx1 - Filial original       							  ���
���          � Expx2 - SC5 posicionado           						  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil        									              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGALOJA                          						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj802Ped(cFilOri, cNumC5)

Local aSc5 		:= {}  	// Array com sc5
Local aItensPed := {}  	// Array com itens do sc5
Local cRet		:= ""	// Retorno com numero do Pedido de Venda	

Default cFilOri	:= ""
Default cNumC5 	:= ""

PRIVATE lMsErroAuto := .F. // Controla erro

//��������������������������Ŀ
//�Gera Array com informa��es�
//� do Pedido de Venda       �
//����������������������������
LJ802Arr(cFilOri, cNumC5, @aSc5, @aItensPed)

If Lj8SalEst(aItensPed)

	//���������������������Ŀ
	//�Grava Pedido de Venda�
	//�����������������������
	MSExecAuto( {|x,y,z| Mata410(x,y,z)} , aSc5, aItensPed, 3)
	//��������������������������������������������������������Ŀ
	//�Verifica se houveram erros durante a exclusao do Pedido.�
	//����������������������������������������������������������
	If lMsErroAuto
		lRet := !lMsErroAuto
	Else
		RecLock("SC5",.F.)
		REPLACE C5_LIBEROK WITH "S"
		MsUnlock()
		
		cRet := SC5->C5_NUM
	
	EndIf
	
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
	EndIf

EndIf

Return(cRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Lj802Leg  � Autor � Venda Clientes        � Data �26/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria Legenda para MBrowse                            	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Lj802Leg()						              			  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil        									              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGALOJA                          						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj802Leg()

Local aCores := {}	// Cores da legenda do Mbrowse

aCores := {	{"ENABLE"		,STR0008},			;      	// 	"Pedido em Aberto"
			{"DISABLE"		,STR0009},			;      	// 	"Pedido Encerrado"
			{"BR_AMARELO"	,STR0010}}	 				// 	"Pedido de Venda Liberado"

If !__lPyme
	Aadd(aCores,{"BR_AZUL",STR0011})					// "Pedido de Venda com Bloqueio de Regra"
	Aadd(aCores,{"BR_LARANJA",STR0012})  				// "Pedido Liberado"
EndIf

If cPaisLoc <> "BRA"
	Aadd(aCores,{"BR_CINZA",STR0013 + " (" + AllTrim(GetDescRem()) + ")"}) //"Pedido de Venda finalizado (Remito)"
Endif

BrwLegenda(cCadastro,STR0014,aCores) // "Legenda"

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Lj8GrMem  � Autor � Venda Clientes        � Data �26/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera Gera dados na tabela MEM - Trans. Pedido de Venda  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �Lj8GrMem(a(Expx1)						              	  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Expx1 - Dados a seren gravados  							  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil        									              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGALOJA                          						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Lj8GrMem(aMem)

Local cNum := GetSxENum("MEM","MEM_CODIGO")  // Gera novo numero de codigo da tabela MEM

DbSelectArea("MEM")

RecLock("MEM",.T.)

REPLACE MEM->MEM_FILIAL 	WITH xFilial("MEM") 
REPLACE MEM->MEM_CODIGO 	WITH cNum 
REPLACE MEM->MEM_FILORI 	WITH aMem[1] 
REPLACE MEM->MEM_FILDES 	WITH aMem[2]
REPLACE MEM->MEM_NPEDOR 	WITH aMem[3] 
REPLACE MEM->MEM_NPEDDE 	WITH aMem[4] 
REPLACE MEM->MEM_ORCORI 	WITH aMem[5] 
REPLACE MEM->MEM_DATTRA 	WITH aMem[6]  
REPLACE MEM->MEM_MOTIVO 	WITH aMem[7] 

MsUnLock()
                        
ConfirmSX8()   // Confirmacao da numeracao utilizada pela funcao GetSxENum

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������� ��
���Programa  �Lj8Filtr 	�Autor  �  Vendas Clientes   � Data �  26/02/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Filtra filial e Motivo destino do Pedido de Venda			  ���  
�������������������������������������������������������������������������͹��
���Sintaxe   � Lj8Filtr(ExpL1)                                     		  ���
�������������������������������������������������������������������������͹�� 
���Retorno   � ExpA1 - Retorno Array com dados da consulta de Filial Dest ���
�������������������������������������������������������������������������͹��
���Uso       � SigaLoja/FrontLoja                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                                                                                                                 
Static Function Lj8Filtr()                                                             

Local oFil             	:= Nil                             	// Objeto para mostrar codigo da filial
Local oMotivo       	:= Nil                              // Objeto para mostrar armazem do produto
Local cFil             	:= Space(FWGETTAMFILIAL)          	// Codigo da Filial
Local aRet				:= Array(2)                      	// Retorno da variavel
Local cMotivo			:= Space(TamSX3("MEM_MOTIVO")[1]) 	// Motivo de Redirecionamento

// Campo verificador se est� sendo chamado pelo Robo
Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

//�����������������������Ŀ
//�Monta tela de consulta �
//������������������������� 
DEFINE MSDIALOG oWindEtq FROM 47,130 TO 200,550 TITLE STR0015 PIXEL OF GetWndDefault() //"Redirecionamento Log�stico"
   
//������Ŀ
//�Filial�
//��������
@ 04, 05 TO 28, 56 LABEL STR0016 OF oWindEtq PIXEL   //"Filial"
@ 13, 10 MSGET oFil VAR cFil F3 "XM0" Picture PesqPict("SC5","C5_FILIAL") SIZE 40,10  OF oWindEtq PIXEL Valid (cFil <> cFilAnt .AND. FWFilExist(cEmpAnt,cFil)) 

//�������Ŀ
//�Motivo �
//���������
@ 04, 58 TO 28, 206 LABEL STR0017 OF oWindEtq PIXEL   //"Motivo"
@ 13, 63 MSGET oMotivo VAR cMotivo  SIZE 130,10  OF oWindEtq PIXEL

DEFINE SBUTTON FROM 060,007 TYPE 1 ACTION (oWindEtq:End(), aRet[1] := cFil, aRet[2] := cMotivo) 	ENABLE OF oWindEtq //"Ok"
DEFINE SBUTTON FROM 060,037 TYPE 2 ACTION (oWindEtq:End(), aRet := {} ) 							ENABLE OF oWindEtq //"Cancelar" 

If !lAutomato
	ACTIVATE MSDIALOG oWindEtq CENTER  
Else
	aRet[1] := cFil 
	aRet[2] := 'Teste Robo'
EndIf
Return(aRet)    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  �Lj8SalEst �Autor  �  Vendas Clientes   � Data �  26/02/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Filtra filial, Produto e Local para consulta de estoque     ���  
�������������������������������������������������������������������������͹��
���Sintaxe   �LJ8FilEst(ExpL1)                                     	  	  ���
�������������������������������������������������������������������������͹��
���Parametro �ExpL1 - Itens para consultar estoque                        ��� 
�������������������������������������������������������������������������͹�� 
���Retorno   �ExpA1 - Retorno Array com dados da consulta de estoque      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                                                                                                                 
Static Function Lj8SalEst(aItensPed)                                                             

Local lRet 		:= .T. 							// Retorno da fun��o
Local aArea 	:= GetArea()					// Backup do Alias
Local nX 		:= 0							// Contador do For
Local cMsg   	:= {}							// Mensagem para alerta
Local nTamProd := TamSX3("C6_PRODUTO")[1]		// Tamanho do campo condigo do produto

Default aItensPed := {}

DbSelectArea("SB2")

For  nX := 1 To Len(aItensPed)

	DbSetOrder(1)
	If DbSeek(aItensPed[nX][1][2]+aItensPed[nX][3][2]+aItensPed[nX][12][2])

	    nTot := SaldoSb2()
	
		If nTot < aItensPed[nX][7][2]
			lRet := .F.    
			If EmPty(cMsg)
				cMsg := STR0018 + cFilAnt + STR0019  +Chr(13) + Chr(13) // "N�o ha estoque suficiente na filial "  ### " para os produtos:"
				cMsg := cMsg + STR0020 + Space(nTamProd -Len(aItensPed[nX][3][2] ) + 10) + STR0021 + CHR(13) // "Produto" ### "Local"
			EndIf
			cMsg := cMsg + aItensPed[nX][3][2] + Space(nTamProd -Len(aItensPed[nX][3][2] ) +10 ) + aItensPed[nX][12][2] + CHR(13)						
		EndIf
	Else
		lRet := .F.    
		If EmPty(cMsg)
			cMsg := STR0018 + cFilAnt + STR0019 +Chr(13) + Chr(13) //"N�o ha estoque suficiente na filial "  ### " para os produtos:"
			cMsg := cMsg + STR0020 + Space(nTamProd -Len(aItensPed[nX][3][2] ) +10 ) + STR0021 + CHR(13)
		EndIf
		cMsg := cMsg + aItensPed[nX][3][2] + Space(nTamProd -Len(aItensPed[nX][3][2] )+ 10 ) + aItensPed[nX][12][2] + CHR(13)				
	EndIF
Next

If !Empty(cMsg)
	Alert(cMsg)
EndIF

RestArea(aArea)

Return(lRet)