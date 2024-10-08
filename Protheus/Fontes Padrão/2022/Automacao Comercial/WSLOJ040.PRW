#INCLUDE "WSLOJ040.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH" 

Function WSLOJ040
Return NIL

WSSERVICE LjCarFid DESCRIPTION STR0008			// "Servico para utiliza��o de cart�o fidelidade"

	WSMETHOD ConCartFid DESCRIPTION STR0009		//"Consultar o Cartao Fidelidade do Cliente"
	WSMETHOD ValCarFid 	DESCRIPTION STR0001		// "Validar cart�o fidelidade"
	WSMETHOD IncSaldFid DESCRIPTION STR0002		// "Incluir saldo no cart�o fidelidade" 
	WSMETHOD ConSaldFid DESCRIPTION STR0003		// "Consultar saldo do cart�o fidelidade"
	WSMETHOD AtuSaldFid DESCRIPTION STR0004		// "Atualizar saldo do cart�o fidelidade"
	WSMETHOD EstSaldFid DESCRIPTION STR0005		// "Estornar saldo do cart�o fidelidade"
	WSMETHOD CalSaldFid DESCRIPTION STR0006		// "Calcula saldo disponviel do cart�o fidelidade"	
	WSMETHOD Conecta   	DESCRIPTION STR0007		// "Conectar"
	
	WSDATA cNumCar 		As String
	WSDATA cConn		As String
	WSDATA dDtValid		As Date
	WSDATA nValor       As Float
	WSDATA cDoc			As String
	WSDATA cSerie		As String
	WSDATA cLoja		As String
	WSDATA cTipo		As String
	WSDATA nSaldoAbat	As Float           
	WSDATA nValPagto	As Float
	WSDATA cEmpPDV		As String
	WSDATA cFilPDV		As String
	WSDATA lSend		As Boolean  Optional
	WSDATA nSaldo 		As Float    Optional
	WSDATA cCodCli		As String	Optional
	WSDATA aCarFidCli	AS Array of WSFidItens

ENDWSSERVICE
WSSTRUCT WSFidItens                         // Itens do Array com Informacoes do Cartao do Cliente.
	WSDATA CartaoFid	AS String               // Numero Cartao Fidelidade
	WSDATA DataValFid	AS Date                 // Data de Validade
	WSDATA StatusFid    AS String               // Status do Cartao
END WSSTRUCT

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValCarFid �Autor  �Leandro Nogueira    � Data �  16/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que retorna se o cart�o fidelidade informado eh     ���
���          � valido ou nao para recarga de saldo                        ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA/SIGAFRT                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD ValCarFid WSRECEIVE cNumCar, cEmpPDV,cFilPDV  WSSEND lSend WSSERVICE LjCarFid
	
lMsErroAuto := .F. 

If FindFunction('LjPreparaWs')
	LjPreparaWs(::cEmpPDV,::cFilPDV)
EndIf

::lSend := Ca280Cart (cNumCar)

Return (.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IncSaldFid�Autor  �Leandro Nogueira    � Data �  16/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para inclusao do saldo/recarga no cartao fidelidade ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA/SIGAFRT                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD IncSaldFid WSRECEIVE 	cNumCar,	dDtValid,	nValor,	cDoc,;
								cSerie,		cLoja, 		cEmpPDV,cFilPDV 	WSSEND lSend WSSERVICE LjCarFid
	
Local aArea	    := GetArea()
Private lMsErroAuto := .F. 

If FindFunction('LjPreparaWs')
	LjPreparaWs(::cEmpPDV,::cFilPDV)
EndIf

::lSend :=Ca280ISld (cNumCar,	dDtValid,	nValor,	cDoc,;
						cSerie,	cLoja)

RestArea( aArea )

Return (.T.)  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConSaldFid�Autor  �Leandro Nogueira    � Data �  22/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para consulta o saldo/recarga no cartao fidelidade  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA/SIGAFRT                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD ConSaldFid WSRECEIVE cNumCar, nValPagto, cEmpPDV,cFilPDV  WSSEND lSend WSSERVICE LjCarFid
	
Local aArea	    := GetArea()
Private lMsErroAuto := .F. 

If FindFunction('LjPreparaWs')
	LjPreparaWs(::cEmpPDV,::cFilPDV)
EndIf

::lSend :=Ca280CSld (cNumCar,nValPagto)

RestArea( aArea )
	
Return (.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtuSaldFid�Autor  �Leandro Nogueira    � Data �  22/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para atualizar o saldo/recarga no cartao fidelidade ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA/SIGAFRT                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD AtuSaldFid WSRECEIVE cNumCar,	nSaldoAbat,	cDoc,	cSerie,	cLoja, cEmpPDV,cFilPDV  WSSEND lSend WSSERVICE LjCarFid
	
Local aArea	    := GetArea()
Private lMsErroAuto := .F. 

If FindFunction('LjPreparaWs')
	LjPreparaWs(::cEmpPDV,::cFilPDV)
EndIf

::lSend :=Ca280ASld (cNumCar,nSaldoAbat,cDoc,cSerie,cLoja)

RestArea( aArea )
	
Return (.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EstSaldFid�Autor  �Leandro Nogueira    � Data �  05/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para estornar  o saldo/recarga no cartao fidelidade ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA/SIGAFRT                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD EstSaldFid WSRECEIVE cNumCar,cDoc,cSerie,cLoja,cTipo, cEmpPDV,cFilPDV  WSSEND lSend WSSERVICE LjCarFid
	
Local aArea	    := GetArea()
Private lMsErroAuto := .F. 

If FindFunction('LjPreparaWs')
	LjPreparaWs(::cEmpPDV,::cFilPDV)
EndIf

::lSend := Ca280ESld(cNumCar,cDoc,cSerie,cLoja,cTipo)

RestArea( aArea )
	
Return (.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CalSaldFid�Autor  �Leandro Nogueira    � Data �  17/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para calcular o saldo do cartao fidelidade 		  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA/SIGAFRT                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD CalSaldFid WSRECEIVE 	cNumCar,cEmpPDV,cFilPDV	WSSEND nSaldo WSSERVICE LjCarFid
	
Local aArea	    := GetArea()
Private lMsErroAuto := .F. 

If FindFunction('LjPreparaWs')
	LjPreparaWs(::cEmpPDV,::cFilPDV)
EndIf

::nSaldo :=Ca280Calc (cNumCar)

RestArea( aArea )

Return (.T.)  



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Conecta   �Autor  �Leandro Nogueira    � Data �  16/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o WS esta conectado					          ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA/SIGAFRT                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD Conecta WSRECEIVE cConn WSSEND lSend WSSERVICE LjCarFid
::lSend := (.T.)

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConCartFid�Autor  �Ricardo Bueno		 � Data �  17/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para Consultar o Cartao Fidelidade do Cliente		  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA/SIGAFRT                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD ConCartFid WSRECEIVE cCodCli,cLoja,cEmpPDV,cFilPDV WSSEND aCarFidCli WSSERVICE LjCarFid
	
Local aArea	    	:= GetArea()        //Grava estado da Tabela
Local aRet		 	:= {}				//Retorno de funcao

Private lMsErroAuto := .F. 

If FindFunction('LjPreparaWs')
	LjPreparaWs(::cEmpPDV,::cFilPDV)
EndIf

aRet := CA280CONCL(cCodCli,cLoja)

//�����������������������������������������Ŀ
//�  Retorna os Dados do Cart�o Fidelidade  �
//�������������������������������������������
If Len(aRet) > 0
	AAdd( Self:aCarFidCli, WSClassNew("WSFIDItens") )	
		  Self:aCarFidCli[1]:CARTAOFID 	 := aRet[1][1]
		  Self:aCarFidCli[1]:DATAVALFID	 := aRet[1][2]
		  Self:aCarFidCli[1]:STATUSFID	 := aRet[1][3]
EndIf		


RestArea( aArea )

Return (.T.) 

