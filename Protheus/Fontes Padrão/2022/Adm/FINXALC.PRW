#INCLUDE "FINXALC.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FXALCGrava� Rev.  �Fernando Radu Muscalu  � Data �18.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gravacao do arquivo FRT - Saldos de Fundo Fixo.			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FXALCGrava(cUser,cGestor,cMoeda,cTpMvto,dData,nValor)       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cUser		- String: Codigo do usuario do gestor      	      ���
���          �cGestor	- String: Codigo do gestor 				          ���
���          �cMoeda	- String: Codigo da Moeda  				      	  ���
���          �cTpMvto	- String: Tipo de movimentacao do saldo	          ���
���          �			1) Saldo Inicial         				          ���
���          �			2) Aprovacao 		    				          ���
���          �			3) Estorno de Aprovacao    				          ���
���          �			4) Aporte	 		    				          ���
���          �			5) Estorno de Aporte	 		    			  ���
���          �dData		- Date: Data da movimentacao do saldo	          ���
���          �nValor	- Numeric: Valor da movimentacao do saldo	      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �lGrvOk	- Boolean: Retorna se houve a gravacao dos dados  ���
���			 �			.t. -> gravacao efetuada.						  ���
���			 �			.f. -> gravacao nao realizada       			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FXALCGrava(cUser,cGestor,cMoeda,cTpMvto,dData,nValor,cNewSeq)

Local dDtSaldo		:= FxAlcCast(dData,"D")
Local cMoedaSld		:= FxAlcCast(cMoeda,"C")
Local nValSld		:= FxAlcCast(nValor,"N")

Local lGrvOk		:= .f.

Local cSequencia    := ""

Default cUser  		:= ""
Default cGestor		:= ""
Default cNewSeq		:= ""

If dDtSaldo	<> nil .and. cMoedaSld <> nil .and. nValSld <> nil
	If !Empty(cUser) .or. !Empty(cGestor)
		If Empty(cUser)
			cCodUsr := FRP->(GetAdvFVal("FRP","FRP_USER",xFilial("FRP") + PadR(cGestor,TamSx3("FRP_COD")[1]),1))
		Else
			cCodUsr := cUser
		Endif

		if Empty(cGestor)
			cCodGes := FRP->(GetAdvFVal("FRP","FRP_COD",xFilial("FRP") + PadR(cUser,TamSx3("FRP_COD")[1]),2))
		Else
			cCodGes := cGestor
		Endif

	Endif

	If !Empty(cMoedaSld) .and. !Empty(cTpMvto) .and. !Empty(dDtSaldo) .and. !Empty(nValSld)

		If Empty(cNewSeq)
			cSequencia := FXALCGNSeq(cCodUsr,cCodGES,cMoedaSld,cTpMvto,dDtSaldo)
		Else
			cSequencia := strzero(val(cNewSeq),TamSx3("FRT_SEQ")[1])
		Endif

		RecLock("FRT",.t.)
			FRT->FRT_FILIAL	:= xFilial("FRT")
			FRT->FRT_USER	:= cCodUsr
			FRT->FRT_CODGES	:= cCodGes
			FRT->FRT_TIPO	:= cTpMvto
			FRT->FRT_MOEDA	:= cMoedaSld
			FRT->FRT_DATA	:= dDtSaldo
			FRT->FRT_SEQ 	:= cSequencia
			FRT->FRT_SALDO	:= nValSld
		FRT->(MsUnlock())

		lGrvOk := .t.

	    If ExistBlock("FINGRVALC")
	    	lGrvOk := ExecBlock("FINGRVALC",.f.,.f.,{cCodUsr,cCodGes,cTpMvto,cMoedaSld,dDtSaldo,cSequencia,nValSld})
	    Endif
	Endif
Endif
Return(lGrvOk)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FXALCValLi� Rev.  �Fernando Radu Muscalu  � Data �18.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se o gestor possui saldo suficiente, dentro de seu   ���
���          �limite, na data de referencia.   							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FXALCValLi(cUser,cGestor,cMoeda,dData,nValor)               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cUser		- String: Codigo do usuario do gestor      	      ���
���          �cGestor	- String: Codigo do gestor 				          ���
���          �cMoeda	- String: Codigo da Moeda  				          ���
���          �dData		- Date: Data da movimentacao do saldo	          ���
���          �nValor	- Numeric: Valor da movimentacao do saldo	      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �lValid	- Boolean: Retorna se ha saldo suficiente.        ���
���			 �			.t. -> Possui saldo.     						  ���
���			 �			.f. -> Nao possui saldo.            			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FXALCValLi(cUser,cGestor,cMoeda,dData,nValor)

Local lValid 	:= .t.

Local cCodUsr	:= ""
Local cCodGes	:= ""

Local nSldNaDt	:= 0

Local dDtSaldo	:= stod("")

Default cUser  		:= ""
Default cGestor		:= ""

dDtSaldo := FxAlcCast(dData,"D")

If Empty(cUser) .and. Empty(cGestor)
	lValid	:= .f.
Else
	If Empty(cUser)
		cCodUsr := FRP->(GetAdvFVal("FRP","FRP_USER",xFilial("FRP") + PadR(cGestor,TamSx3("FRP_COD")[1]),1))
	Elseif Empty(cGestor)
		cCodGes := FRP->(GetAdvFVal("FRP","FRP_COD",xFilial("FRP") + PadR(cUser,TamSx3("FRP_COD")[1]),2))
	Else
		cCodGes := cGestor
	Endif
Endif

aSaldo := fXAlcSld(cMoeda,dDtSaldo,cCodGes) 	//monta array com os movimentos
nSldNaDt := fxAlcSldFim(aSaldo)				//traz o saldo final em relacao aos movimentos de aSaldo

If nValor > nSldNaDt
	lValid := .f.
Endif


Return(lValid)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fXAlcSld  � Rev.  �Fernando Radu Muscalu  � Data �18.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array com as movimentacoes de saldo do fundo fixo     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fXAlcSld(cFXAlcMoeda,dFXAlcData,cFXAlcGes,lInterface)       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cFXAlcMoeda	- String: Codigo da Moeda				      ���
���          �dFXAlcData	- Date: Data da movimentacao do saldo	      ���
���          �cFXAlcGes		- String: Codigo do gestor 				      ���
���          �lInterface	- Boolean: Uso de Interface   				  ���
���          �				.t. - Utiliza-se de interface (ListBox)		  ���
���          �				.f. - Nao utiliza-se de interface (ListBox)	  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aMvto	- Array: Retorna array com os dados das movimentacoes ���
���			 �	aMvto[n,1]-> Char: Sequencia de lancamento do saldo		  ���
���			 �	aMvto[n,2]-> Char: Tipo de Movimentacao        			  ���
���			 �				1) Saldo Inicial         			          ���
���          �				2) Aprovacao 		    			          ���
���          �				3) Estorno de Aprovacao				          ���
���          �				4) Aporte	 		   				          ���
���          �				5) Estorno de Aporte 		    			  ���
���			 �	aMvto[n,3]-> Date: Data de Movimentacao        			  ���
���			 �	aMvto[n,4]-> Numeric: Saldo da movimentacao    			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fXAlcSld(cFXAlcMoeda,dFXAlcData,cFXAlcGes,lInterface)

Local cQry 		:= ""
Local cDtIni	:= ""
Local cDtFim	:= ""
Local cNextAlias:= GetNextAlias()

Local aMvto		:= {}
Local aFRP		:= {}
Local aMvtoSld	:= {}

Local nSaldo	:= 0
Local nPos		:= 0
Local nI		:= 0

Local lGrava	:= .f.

Default lInterface	:= .f.
Default dFXAlcData	:= stod("")	//a informacao da data e obrigatoria quando for uma inclusao ou a demonstracao de saldos na data

#IFNDEF TOP
	Help(" ",1,"fXAlcSldTOP",,STR0001,1,0)	//"Funcionalidade v�lida somente para ambientes com DBACCESS. Contacte o administrador."
	Return()
#ENDIF

If Empty(dFXAlcData)
	cDtIni	:= ""
	cDtFim	:= dtos(dDatabase)
Else
	cDtIni 	:= dTos(dFXAlcData - fxAlcDtIni(FRP->(GetAdvfVal("FRP","FRP_TIPO",xFilial("FRP")+Alltrim(cFxAlcGes),1))))
	cDtFim	:= dtos(dFXAlcData)
Endif

cQry := "SELECT " + chr(13) + chr(10)
cQry += "	FRT_SEQ,  " + chr(13) + chr(10)
cQry += "	FRT_TIPO,  " + chr(13) + chr(10)
cQry += "	FRT_MOEDA,  " + chr(13) + chr(10)
cQry += "	FRT_DATA,  " + chr(13) + chr(10)
cQry += "	FRT_SALDO  " + chr(13) + chr(10)
cQry += "FROM  " + chr(13) + chr(10)
cQry += "	" + RetSQLName("FRT") + " FRT " + chr(13) + chr(10)
cQry += "WHERE  " + chr(13) + chr(10)
cQry += "	FRT_FILIAL = '"+xFilial("FRT")+"'  " + chr(13) + chr(10)
cQry += "	AND  " + chr(13) + chr(10)
cQry += "	FRT_CODGES = '"+cFXAlcGes+"'  " + chr(13) + chr(10)
cQry += "	AND	   " + chr(13) + chr(10)
cQry += "	FRT_MOEDA = '"+cFXAlcMoeda+"'
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
cQry += "ORDER BY " + chr(13) + chr(10)
cQry += "	FRT_DATA, 		" + chr(13) + chr(10)
cQry += "	FRT_TIPO, " + chr(13) + chr(10)
cQry += "	FRT_SEQ "

cQry := ChangeQuery(cQry)

If Select(cNextAlias) > 0
	(cNextAlias)->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), cNextAlias, .T., .F.)

(cNextAlias)->(dbGoTop())

While (cNextAlias)->(!Eof())
	aAdd(aMvto,{(cNextAlias)->FRT_SEQ,Alltrim((cNextAlias)->FRT_TIPO),stod((cNextAlias)->FRT_DATA),(cNextAlias)->FRT_SALDO})
	(cNextAlias)->(DbSkip())
EndDo

If ( nPos := aScan(aMvto,{|x| alltrim(x[1]) == Strzero(1,TamSX3("FRT_SEQ")[1]) .and. alltrim(x[2]) == "1"}) ) == 0

	//Se o arquivo nao possui nenhuma movimentacao, significa que mudou o periodo, logo deve ser gerado uma
	//movimentacao de saldo inicial, para este novo periodo.
	aFRP := FRP->(GetAdvfVal("FRP",{"FRP_LIMITE","FRP_USER"},xFilial("FRP")+Alltrim(cFxAlcGes),1,{0,""}))
	nSaldo := aFRP[1]

	If nSaldo > 0 .and. len(aFRP) > 0
		Begin Transaction
			//Geracao do movimento para saldo inicial da sequencia 000001
			lGrava := FXALCGrava(aFRP[2],cFxAlcGes,cFXAlcMoeda,"1",dFXAlcData,nSaldo,"000001")
		End Transaction
	Endif

	If lGrava
		aMvto := {}
		aAdd(aMvto,{FRT->FRT_SEQ,Alltrim(FRT->FRT_TIPO),FRT->FRT_DATA,FRT->FRT_SALDO})
	Endif

	nPos := 1
Endif

//Monta vetor somente com os movimentos a partir do saldo inicial,
For nI := nPos to len(aMvto)
	aAdd(aMvtoSld,{aMvto[nI,1],aMvto[nI,2],aMvto[nI,3],aMvto[nI,4]})
Next nI

If lInterface .and. len(aMvto) == 0
	aAdd(aMvtoSld,{"","","",0})
Endif

(cNextAlias)->(DbCloseArea())

Return(aMvtoSld)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fxAlcDtIni� Rev.  �Fernando Radu Muscalu  � Data �18.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Numero de dias de acordo com o tipo de limite				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fxAlcDtIni(cTipoLim)							              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cTipoLim	- String: Tipo de limite do gestor      	      ���
���          �				1) Limite Diario							  ���
���          �				2) Limite Semanal		  				      ���
���          �				3) Limite Mensal	          				  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �nDias	- Numeric: Retorna o nro de dias de acorod com o      ���
���			 �tipo de limite passado por parametro 						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fxAlcDtIni(cTipoLim)

Local nDias := 0

Do Case
	Case cTipoLim == "1" //DIARIO
		nDias := 0
	Case cTipoLim == "2" //SEMANAL
		nDias := 6
	Case cTipoLim == "3" //MENSAL
		nDias := 29
End Do

Return(nDias)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �fxAlcSldFim� Rev.  �Fernando Radu Muscalu  � Data �18.03.2011���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Saldo Final das movimentacoes								   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �fxAlcSldFim(aDados)							               ���
��������������������������������������������������������������������������Ĵ��
���Parametros�aDados	- Array: Array com as movimentacoes      	       ���
���			 �	aDados[n,1]-> Char: Sequencia de lancamento do saldo	   ���
���			 �	aDados[n,2]-> Char: Tipo de Movimentacao        		   ���
���			 �				1) Saldo Inicial         			           ���
���          �				2) Aprovacao 		    			           ���
���          �				3) Estorno de Aprovacao				           ���
���          �				4) Aporte	 		   				           ���
���          �				5) Estorno de Aporte 		    			   ���
���			 �	aDados[n,3]-> Date: Data de Movimentacao       			   ���
���			 �	aDados[n,4]-> Numeric: Saldo da movimentacao	  		   ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �nRetValue	- Numeric: Retorna o valor do saldo final          ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function fxAlcSldFim(aDados)

Local nRetValue 	:= 0
Local nI			:= 0

Local lSldInicial   := .f.

For nI := 1 to len(aDados)
	//Como eu posso ter varias entradas de saldo inicial na mesma data para o mesmo gestor, o saldo final e calculado a partir da ultima sequencia do movimento de saldo inicial
	If aDados[nI,2] $ "1|3"
		If aDados[nI,2] == "1" .and. !lSldInicial
			nRetValue += UltSldInic(aDados)
			lSldInicial := .t.
		Else
			If aDados[nI,2] == "3"
				nRetValue += aDados[nI,4]
			Endif
		Endif
	Else
		nRetValue -= aDados[nI,4]
	Endif
Next nI

Return(nRetValue)



/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �UltSldInic � Rev.  �Fernando Radu Muscalu  � Data �19.03.2011���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna o ultimo lancamento do Saldo Inicial.				   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �UltSldInic(aDados)							               ���
��������������������������������������������������������������������������Ĵ��
���Parametros�aDados	- Array: Array com as movimentacoes      	       ���
���			 �	aDados[n,1]-> Char: Sequencia de lancamento do saldo	   ���
���			 �	aDados[n,2]-> Char: Tipo de Movimentacao        		   ���
���			 �				1) Saldo Inicial         			           ���
���          �				2) Aprovacao 		    			           ���
���          �				3) Estorno de Aprovacao				           ���
���          �				4) Aporte	 		   				           ���
���          �				5) Estorno de Aporte 		    			   ���
���			 �	aDados[n,3]-> Date: Data de Movimentacao       			   ���
���			 �	aDados[n,4]-> Numeric: Saldo da movimentacao	  		   ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �nValor - Numeric: Retorna o valor do ultimo saldo inicial    ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function UltSldInic(aDados)

Local nValor	:= 0
Local nI		:= 0

Local aAux		:= {}

For nI := 1 to len(aDados)
	If aDados[nI,2] == "1"
		aAdd(aAux,{aDados[nI,1],aDados[nI,2],aDados[nI,3],aDados[nI,4]})
	Endif
Next nI

If len(aAux) > 0
	aSort(aAux,,,{|x,y| dtos(y[3]) + y[1] < dtos(x[3]) + x[1]})
	nValor := aAux[1,4]
Endif

Return(nValor)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �FxAlcCast	 � Rev.  �Fernando Radu Muscalu  � Data �18.03.2011���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Conversao de tipos de dados.As conversoes que sao realizadas:���
���          �	- Data para caracter									   ���
���          �	- Numerico para caracter								   ���
���          �	- Data para caracter									   ���
���          �	- Caracter para Numerico								   ���
���          �	- Caracter para Data									   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �FxAlcCast(xDataConv,cTipoConv)				               ���
��������������������������������������������������������������������������Ĵ��
���Parametros�xDataConv	- Any: Dado a ser convertido		      	       ���
���			 �cTipoConv	- Char: Tipo para qual sera convertido("C","D","N")���
��������������������������������������������������������������������������Ĵ��
���Retorno   �nRetValue	- Numeric: Retorna o valor do saldo final          ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function FxAlcCast(xDataConv,cTipoConv)

Local xData

Do Case
	Case cTipoConv == "C"
		If valtype(xDataConv) == "D"
			xData := {dtoc(xDataConv),dtos(xDataConv)}
		Elseif Valtype(xDataConv) == "N"
			xData := Alltrim(str(xDataConv))
		Elseif Valtype(xDataConv) == "C"
			xData := xDataConv
		Else
			xData := nil
		Endif
	Case cTipoConv == "N"
		If Valtype(xDataConv) == "C"
			xData	:= strTran(xDataConv,".","")
			xData 	:= StrTran(xData,",",".")
			xData 	:= Val(xData)
		Elseif Valtype(xDataConv) == "N"
			xData := xDataConv
		Else
			xData := nil
		Endif
	Case cTipoConv == "D"
		If ValType(xDataConv) == "C"
			If At("/",xDataConv) > 0
				xData := ctod(xDataConv)
			Else
				xData := stod(xDataConv)
			Endif
		Elseif Valtype(xDataConv) == "D"
			xData := xDataConv
		Else
			xData := nil
		Endif
	Otherwise
		xData := xDataConv
End Case

Return(xData)

User Function MyTest(cGestor,cUserGes,cMoeda,dData,nValor,cTipo)

If FXALCValLi(cUserGes,cGestor,cMoeda,dData,nValor)
	lGrava := FXALCGrava(cUserGes,cGestor,cMoeda,cTipo,dData,nValor)
	If lGrava
		Alert("Tudo certo")
	Endif
Endif

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FxAlcChkTP� Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se ha registros de acordo com os tipos de movto.	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FxAlcChkTP(aDados,cTiposMVT)							      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�aDados	- Array: Array com as movimentacoes      	      ���
���			 �	aDados[n,1]-> Char: Sequencia de lancamento do saldo	  ���
���			 �	aDados[n,2]-> Char: Tipo de Movimentacao        		  ���
���			 �				1) Saldo Inicial         			          ���
���          �				2) Aprovacao 		    			          ���
���          �				3) Estorno de Aprovacao				          ���
���          �				4) Aporte	 		   				          ���
���          �				5) Estorno de Aporte 		    			  ���
���			 �	aDados[n,3]-> Date: Data de Movimentacao       			  ���
���			 �	aDados[n,4]-> Numeric: Saldo da movimentacao	  		  ���
���          �cTiposMvt	- String: Tipo de movimentacao do saldo	          ���
���          �			1) Saldo Inicial         				          ���
���          �			2) Aprovacao 		    				          ���
���          �			3) Estorno de Aprovacao    				          ���
���          �			4) Aporte	 		    				          ���
���          �			5) Estorno de Aporte	 		    			  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �lGrvOk	- Boolean: Retorna se ha registros com os tipos   ���
���			 �de movimento que foi passado pela string					  ���
���			 �			.t. -> Existem registros.						  ���
���			 �			.f. -> Nao gravacao nao realizada      			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FxAlcChkTP(aDados,cTiposMVT)

Local lRet 	:= .f.

Local nI	:= 0

For nI := 1 to len(aDados)
	If aDados[nI,2] $ cTiposMVT
		lRet := .t.
		Exit
	Endif
Next nI

Return(lRet)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �FxAlcExclui� Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Exclui os movimentos de saldos de FRT.					   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �FxAlcExclui(cCodUsr,cCodGes,cMoeda,aTpMvto,dData)			   ���
��������������������������������������������������������������������������Ĵ��
���Parametros�cCodUsr	- String: codigo do usuario gestor      	       ���
���			 �cCodGes	- String: codigo do gestor	  					   ���
���			 �cMoeda	- String: codigo da Moeda		        		   ���
���			 �aTpMvto	- Array: com os tipos que serao excluidos		   ���
���          �	aTpMvto[n] - Caracter: Tipo de movimentacao.			   ���
���          �				Ex: {"1","2","3","4","4"}					   ���
���          �dData	- Data: Data final da movimentacao			           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �lExcluido	- Boolean: Retorna se houve exclusao		       ���
���			 �de movimento que foi passado pela string					   ���
���			 �			.t. -> Excluido.								   ���
���			 �			.f. -> Nao Excluido				      			   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function FxAlcExclui(cCodUsr,cCodGes,cMoeda,aTpMvto,dData)

Local aSaveArea	:= GetArea()

Local cQry		:= ""
Local cDtIni	:= ""
Local cDtFim	:= ""
Local cAlcUsr	:= ""
Local cAlcGes	:= ""
Local cNextalias:= GetNextAlias()

Local lExcluido	:= .f.

Default cCodUsr	:= ""
Default cCodGes	:= ""
Default dData	:= stod("")
Default aTpMvto	:= {}

#IFNDEF TOP

	Help(" ",1,"FxAlcExcluiTOP",,STR0001,1,0) //"Funcionalidade v�lida somente para ambientes com DBACCESS. Contacte o administrador."
	Return(.f.)
#ENDIF

If !Empty(dData)
	cDtIni := dTos(dData - fxAlcDtIni(FRP->(GetAdvfVal("FRP","FRP_TIPO",xFilial("FRP")+Alltrim(cCodGes),1))))
	cDtFim := dTos(dData)
Endif

If !Empty(cCodUsr) .or. !Empty(cCodGes)
	If Empty(cCodUsr)
		cAlcUsr := FRP->(GetAdvFVal("FRP","FRP_USER",xFilial("FRP") + PadR(cCodGes,TamSx3("FRP_COD")[1]),1))
	Else
		cAlcUsr := cCodUsr
	Endif

	If Empty(cCodGes)
		cAlcGes := FRP->(GetAdvFVal("FRP","FRP_COD",xFilial("FRP") + PadR(cCodUsr,TamSx3("FRP_COD")[1]),2))
	Else
		cAlcGes := cCodGes
	Endif
Endif

If !Empty(cMoeda)
	cQry := "SELECT " + chr(13) + chr(10)
	cQry += "	R_E_C_N_O_ FRTREC  " + chr(13) + chr(10)
	cQry += "FROM " + RetSQLName("FRT") + " FRT " + chr(13) + chr(10)
	cQry += "WHERE " + chr(13) + chr(10)
	cQry += "	FRT_FILIAL = '"+xFilial("FRP")+"' " + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	FRT_USER = '"+cAlcUsr+"' " + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	FRT_CODGES = '"+cAlcGes+"' " + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	FRT_MOEDA = '"+ cMoeda + "' " + chr(13) + chr(10)
	cQry += FXAlcQryGetIn(aTpMvto) + chr(13) + chr(10)
	cQry += "	FRT_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' " + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	D_E_L_E_T_ = ' ' "

	If Select(cNextAlias) > 0
		(cNextAlias)->(DbCloseArea())
	Endif

	cQry := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), cNextAlias, .T., .F.)

	(cNextAlias)->(DbGotop())

	If (cNextAlias)->(!Eof())
		While (cNextAlias)->(!Eof())
			FRT->(DbGoto((cNextAlias)->FRTREC))
			Reclock("FRT",.f.)
				FRT->(DbDelete())
			FRT->(MsUnlock())
			(cNextAlias)->(DbSkip())
		EndDo
	Endif
	lExcluido := .T.
Endif

(cNextAlias)->(DbCloseArea())

RestArea(aSaveArea)

Return(lExcluido)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �FXAlcQryGetIn� Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Monta filtro de query com os tipos de movimentos da tabela  	 ���
���          �de saldos de Fundo Fixo						 			  	 ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �FXAlcQryGetIn(aMvtos)										  	 ���
����������������������������������������������������������������������������Ĵ��
���Parametros�aMvtos	- Array: com os tipos que serao excluidos		   	 ���
���          �	aMvtos[n] - Caracter: Tipo de movimentacao.				  	 ���
���          �				Ex: {"1","2","3","4","5"}					  	 ���
����������������������������������������������������������������������������Ĵ��
���Retorno   �cRetorno	- String: Retorna o filtro com os tipos de mvto.  	 ���
���			 �de movimento que foi passado pela string					  	 ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function FXAlcQryGetIn(aMvtos)

Local cRetorno 	:= ""

Local nI		:= 0

If len(aMvtos) > 1
	cRetorno := " AND FRT_TIPO IN("

	For nI := 1 to len(aMvtos)
		cRetorno += "'" + aMvtos[nI] + "',"
	Next nI

	cRetorno := Substr(cRetorno,1,Len(Alltrim(cRetorno)-1))
	cRetorno += ") AND "
ElseIf len(aMvtos) == 1
	cRetorno := " AND FRT_TIPO = '"+aMvtos[1]+"' AND "
Endif

Return(cRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FxAlcVMo	� Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se existe a moeda especificada pelo parametro.	A 	  ���
���			 �verificacao se da atraves da existencia do parametro		  ���
���			 �"MV_MOEDA" + cMoeda										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FxAlcVMo(cMoeda)											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cMoeda	- String: Codigo da Moeda						  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �lRet	- Boolean: Retorna se moeda existe.    				  ���
���			 �		.t. - existe										  ���
���			 �		.f. - nao existe									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FxAlcVMo(cMoeda)

Local lRet := .t.
Local aAreaSX6	:= SX6->(GetArea())

SX6->(DbSetOrder(1))

If !SX6->(Dbseek(xFilial("SX6") + "MV_MOEDA" + cMoeda ))
	Help(" ",1,"FxAlcVMo",,STR0002,1,0)	//"Moeda selecionada n�o est� cadastrada."
	lRet := .f.
Endif

RestArea(aAreaSX6)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FXALCGNSeq� Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Sequenciamento das movimentacoes de acordo com o tipo de 	  ���
���			 �periodo do gestor e da data de referencia passada.		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FXALCGNSeq(cCodUsr,cCodGES,cMoedaSld,cTpMvto,dDtSaldo)	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCodUsr	- String: Codigo do Usuario.					  ���
���			 �cCodGes	- String: Codigo do gestor.						  ���
���			 �cMoedaSld	- String: Codigo da Moeda						  ���
���          �cTpMvto	- String: Tipo de movimentacao do saldo	          ���
���          �			1) Saldo Inicial         				          ���
���          �			2) Aprovacao 		    				          ���
���          �			3) Estorno de Aprovacao    				          ���
���          �			4) Aporte	 		    				          ���
���          �			5) Estorno de Aporte	 		    			  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �cSeq	- String: Proxima sequencia para o tipo escolhido.	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FXALCGNSeq(cCodUsr,cCodGES,cMoedaSld,cTpMvto,dDtSaldo)

Local cQry		:= ""
Local cDtIni	:= ""
Local cDtFim	:= ""
Local cNextAlias:= GetNextAlias()
Local cSeq		:= ""
Local cInTipo	:= ""

#IFNDEF TOP
	Help(" ",1,"FXALCGNSeqTOP",,STR0001,1,0)	//"Funcionalidade v�lida somente para ambientes com DBACCESS."
	Return("")
#ENDIF

cDtIni 	:= dtos( FXAlcPerRet(dDtSaldo,cCodGES) ) //dtos(dDtSaldo)

If Empty(cDtIni)
	cDtIni := dtos(dDtSaldo)
Endif

cDtFim	:= dTos(dDtSaldo + fxAlcDtIni(FRP->(GetAdvfVal("FRP","FRP_TIPO",xFilial("FRP")+Alltrim(cCodGES),1))))

cQry := "SELECT " + CHR(13) + chr(10)
cQry += "	MAX(FRT_SEQ) ULT_SEQ " + CHR(13) + chr(10)
cQry += "FROM " + CHR(13) + chr(10)
cQry += "	" + RetSQLName("FRT") + " FRT " + chr(13) + chr(10)
cQry += "WHERE " + CHR(13) + chr(10)
cQry += "	FRT_FILIAL = '"+xFilial("FRT")+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT_USER = '"+cCodUsr+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT_CODGES = '"+cCodGes+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT_MOEDA = '"+cMoedaSld+"' " + chr(13) + chr(10)
cQry += "	AND
cQry += "	FRT_TIPO = '"+cTpMvto+"' " + CHR(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT.D_E_L_E_T_ = ' ' " + CHR(13) + chr(10)

cQry := ChangeQuery(cQry)

If Select(cNextAlias) > 0
	(cNextAlias)->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), cNextAlias, .T., .F.)

(cNextAlias)->(dbGoTop())

cSeq := StrZero( Val((cNextAlias)->ULT_SEQ) + 1 , TamSx3("FRT_SEQ")[1] )

(cNextAlias)->(DbCloseArea())

Return(cSeq)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FXALCGNSeq� Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Sequenciamento das movimentacoes de acordo com o tipo de 	  ���
���			 �periodo do gestor e da data de referencia passada.		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FXAlcPerRet(dData,cCodGes)								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�dData	- Data: Data do movimento.					  		  ���
���			 �cCodGes	- String: Codigo do gestor.						  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �dRet	- Data: data inicial do perido do gestor.			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FXAlcPerRet(dData,cCodGes)

Local dRet	:= stod("")

Local cTipoLim  := ""
Local cQry		:= ""
Local cNext 	:= GetNextAlias()

cTipoLim := FRP->(GetAdvFVal("FRP","FRP_TIPO",xFilial("FRP") + PadR(cCodGes,TamSx3("FRP_COD")[1]),1))

cQry := "SELECT " + chr(13) + chr(10)
cQry += "	MAX(FRT_DATA) FRT_DATA " + chr(13) + chr(10)
cQry += "FROM " + chr(13) + chr(10)
cQry += "	" + RetSQLName("FRT") + " FRT " + chr(13) + chr(10)
cQry += "WHERE " + chr(13) + chr(10)
cQry += "	FRT_CODGES = '" + cCodGes + "' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT_SEQ = '000001' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT_TIPO = '1' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT_DATA <= '" + dtos(dData) + "' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRT.D_E_L_E_T_ = ' ' "

If Select(cNext) > 0
	(cNext)->(DbCloseArea())
Endif

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), cNext, .T., .F.)

dRet := stod( (cNext)->FRT_DATA )

(cNext)->(DbCloseArea())
Return(dRet)