#INCLUDE "FINXALC.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FXALCGrava³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacao do arquivo FRT - Saldos de Fundo Fixo.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FXALCGrava(cUser,cGestor,cMoeda,cTpMvto,dData,nValor)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cUser		- String: Codigo do usuario do gestor      	      ³±±
±±³          ³cGestor	- String: Codigo do gestor 				          ³±±
±±³          ³cMoeda	- String: Codigo da Moeda  				      	  ³±±
±±³          ³cTpMvto	- String: Tipo de movimentacao do saldo	          ³±±
±±³          ³			1) Saldo Inicial         				          ³±±
±±³          ³			2) Aprovacao 		    				          ³±±
±±³          ³			3) Estorno de Aprovacao    				          ³±±
±±³          ³			4) Aporte	 		    				          ³±±
±±³          ³			5) Estorno de Aporte	 		    			  ³±±
±±³          ³dData		- Date: Data da movimentacao do saldo	          ³±±
±±³          ³nValor	- Numeric: Valor da movimentacao do saldo	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lGrvOk	- Boolean: Retorna se houve a gravacao dos dados  ³±±
±±³			 ³			.t. -> gravacao efetuada.						  ³±±
±±³			 ³			.f. -> gravacao nao realizada       			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FXALCValLi³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se o gestor possui saldo suficiente, dentro de seu   ³±±
±±³          ³limite, na data de referencia.   							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FXALCValLi(cUser,cGestor,cMoeda,dData,nValor)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cUser		- String: Codigo do usuario do gestor      	      ³±±
±±³          ³cGestor	- String: Codigo do gestor 				          ³±±
±±³          ³cMoeda	- String: Codigo da Moeda  				          ³±±
±±³          ³dData		- Date: Data da movimentacao do saldo	          ³±±
±±³          ³nValor	- Numeric: Valor da movimentacao do saldo	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lValid	- Boolean: Retorna se ha saldo suficiente.        ³±±
±±³			 ³			.t. -> Possui saldo.     						  ³±±
±±³			 ³			.f. -> Nao possui saldo.            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fXAlcSld  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array com as movimentacoes de saldo do fundo fixo     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fXAlcSld(cFXAlcMoeda,dFXAlcData,cFXAlcGes,lInterface)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cFXAlcMoeda	- String: Codigo da Moeda				      ³±±
±±³          ³dFXAlcData	- Date: Data da movimentacao do saldo	      ³±±
±±³          ³cFXAlcGes		- String: Codigo do gestor 				      ³±±
±±³          ³lInterface	- Boolean: Uso de Interface   				  ³±±
±±³          ³				.t. - Utiliza-se de interface (ListBox)		  ³±±
±±³          ³				.f. - Nao utiliza-se de interface (ListBox)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aMvto	- Array: Retorna array com os dados das movimentacoes ³±±
±±³			 ³	aMvto[n,1]-> Char: Sequencia de lancamento do saldo		  ³±±
±±³			 ³	aMvto[n,2]-> Char: Tipo de Movimentacao        			  ³±±
±±³			 ³				1) Saldo Inicial         			          ³±±
±±³          ³				2) Aprovacao 		    			          ³±±
±±³          ³				3) Estorno de Aprovacao				          ³±±
±±³          ³				4) Aporte	 		   				          ³±±
±±³          ³				5) Estorno de Aporte 		    			  ³±±
±±³			 ³	aMvto[n,3]-> Date: Data de Movimentacao        			  ³±±
±±³			 ³	aMvto[n,4]-> Numeric: Saldo da movimentacao    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	Help(" ",1,"fXAlcSldTOP",,STR0001,1,0)	//"Funcionalidade válida somente para ambientes com DBACCESS. Contacte o administrador."
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fxAlcDtIni³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Numero de dias de acordo com o tipo de limite				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fxAlcDtIni(cTipoLim)							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTipoLim	- String: Tipo de limite do gestor      	      ³±±
±±³          ³				1) Limite Diario							  ³±±
±±³          ³				2) Limite Semanal		  				      ³±±
±±³          ³				3) Limite Mensal	          				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nDias	- Numeric: Retorna o nro de dias de acorod com o      ³±±
±±³			 ³tipo de limite passado por parametro 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fxAlcSldFim³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Saldo Final das movimentacoes								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fxAlcSldFim(aDados)							               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aDados	- Array: Array com as movimentacoes      	       ³±±
±±³			 ³	aDados[n,1]-> Char: Sequencia de lancamento do saldo	   ³±±
±±³			 ³	aDados[n,2]-> Char: Tipo de Movimentacao        		   ³±±
±±³			 ³				1) Saldo Inicial         			           ³±±
±±³          ³				2) Aprovacao 		    			           ³±±
±±³          ³				3) Estorno de Aprovacao				           ³±±
±±³          ³				4) Aporte	 		   				           ³±±
±±³          ³				5) Estorno de Aporte 		    			   ³±±
±±³			 ³	aDados[n,3]-> Date: Data de Movimentacao       			   ³±±
±±³			 ³	aDados[n,4]-> Numeric: Saldo da movimentacao	  		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nRetValue	- Numeric: Retorna o valor do saldo final          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UltSldInic ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³19.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o ultimo lancamento do Saldo Inicial.				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³UltSldInic(aDados)							               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aDados	- Array: Array com as movimentacoes      	       ³±±
±±³			 ³	aDados[n,1]-> Char: Sequencia de lancamento do saldo	   ³±±
±±³			 ³	aDados[n,2]-> Char: Tipo de Movimentacao        		   ³±±
±±³			 ³				1) Saldo Inicial         			           ³±±
±±³          ³				2) Aprovacao 		    			           ³±±
±±³          ³				3) Estorno de Aprovacao				           ³±±
±±³          ³				4) Aporte	 		   				           ³±±
±±³          ³				5) Estorno de Aporte 		    			   ³±±
±±³			 ³	aDados[n,3]-> Date: Data de Movimentacao       			   ³±±
±±³			 ³	aDados[n,4]-> Numeric: Saldo da movimentacao	  		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nValor - Numeric: Retorna o valor do ultimo saldo inicial    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FxAlcCast	 ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Conversao de tipos de dados.As conversoes que sao realizadas:³±±
±±³          ³	- Data para caracter									   ³±±
±±³          ³	- Numerico para caracter								   ³±±
±±³          ³	- Data para caracter									   ³±±
±±³          ³	- Caracter para Numerico								   ³±±
±±³          ³	- Caracter para Data									   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FxAlcCast(xDataConv,cTipoConv)				               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³xDataConv	- Any: Dado a ser convertido		      	       ³±±
±±³			 ³cTipoConv	- Char: Tipo para qual sera convertido("C","D","N")³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nRetValue	- Numeric: Retorna o valor do saldo final          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FxAlcChkTP³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se ha registros de acordo com os tipos de movto.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FxAlcChkTP(aDados,cTiposMVT)							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aDados	- Array: Array com as movimentacoes      	      ³±±
±±³			 ³	aDados[n,1]-> Char: Sequencia de lancamento do saldo	  ³±±
±±³			 ³	aDados[n,2]-> Char: Tipo de Movimentacao        		  ³±±
±±³			 ³				1) Saldo Inicial         			          ³±±
±±³          ³				2) Aprovacao 		    			          ³±±
±±³          ³				3) Estorno de Aprovacao				          ³±±
±±³          ³				4) Aporte	 		   				          ³±±
±±³          ³				5) Estorno de Aporte 		    			  ³±±
±±³			 ³	aDados[n,3]-> Date: Data de Movimentacao       			  ³±±
±±³			 ³	aDados[n,4]-> Numeric: Saldo da movimentacao	  		  ³±±
±±³          ³cTiposMvt	- String: Tipo de movimentacao do saldo	          ³±±
±±³          ³			1) Saldo Inicial         				          ³±±
±±³          ³			2) Aprovacao 		    				          ³±±
±±³          ³			3) Estorno de Aprovacao    				          ³±±
±±³          ³			4) Aporte	 		    				          ³±±
±±³          ³			5) Estorno de Aporte	 		    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lGrvOk	- Boolean: Retorna se ha registros com os tipos   ³±±
±±³			 ³de movimento que foi passado pela string					  ³±±
±±³			 ³			.t. -> Existem registros.						  ³±±
±±³			 ³			.f. -> Nao gravacao nao realizada      			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FxAlcExclui³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exclui os movimentos de saldos de FRT.					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FxAlcExclui(cCodUsr,cCodGes,cMoeda,aTpMvto,dData)			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodUsr	- String: codigo do usuario gestor      	       ³±±
±±³			 ³cCodGes	- String: codigo do gestor	  					   ³±±
±±³			 ³cMoeda	- String: codigo da Moeda		        		   ³±±
±±³			 ³aTpMvto	- Array: com os tipos que serao excluidos		   ³±±
±±³          ³	aTpMvto[n] - Caracter: Tipo de movimentacao.			   ³±±
±±³          ³				Ex: {"1","2","3","4","4"}					   ³±±
±±³          ³dData	- Data: Data final da movimentacao			           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExcluido	- Boolean: Retorna se houve exclusao		       ³±±
±±³			 ³de movimento que foi passado pela string					   ³±±
±±³			 ³			.t. -> Excluido.								   ³±±
±±³			 ³			.f. -> Nao Excluido				      			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

	Help(" ",1,"FxAlcExcluiTOP",,STR0001,1,0) //"Funcionalidade válida somente para ambientes com DBACCESS. Contacte o administrador."
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FXAlcQryGetIn³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta filtro de query com os tipos de movimentos da tabela  	 ³±±
±±³          ³de saldos de Fundo Fixo						 			  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FXAlcQryGetIn(aMvtos)										  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aMvtos	- Array: com os tipos que serao excluidos		   	 ³±±
±±³          ³	aMvtos[n] - Caracter: Tipo de movimentacao.				  	 ³±±
±±³          ³				Ex: {"1","2","3","4","5"}					  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRetorno	- String: Retorna o filtro com os tipos de mvto.  	 ³±±
±±³			 ³de movimento que foi passado pela string					  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FxAlcVMo	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se existe a moeda especificada pelo parametro.	A 	  ³±±
±±³			 ³verificacao se da atraves da existencia do parametro		  ³±±
±±³			 ³"MV_MOEDA" + cMoeda										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FxAlcVMo(cMoeda)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMoeda	- String: Codigo da Moeda						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: Retorna se moeda existe.    				  ³±±
±±³			 ³		.t. - existe										  ³±±
±±³			 ³		.f. - nao existe									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FxAlcVMo(cMoeda)

Local lRet := .t.
Local aAreaSX6	:= SX6->(GetArea())

SX6->(DbSetOrder(1))

If !SX6->(Dbseek(xFilial("SX6") + "MV_MOEDA" + cMoeda ))
	Help(" ",1,"FxAlcVMo",,STR0002,1,0)	//"Moeda selecionada não está cadastrada."
	lRet := .f.
Endif

RestArea(aAreaSX6)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FXALCGNSeq³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Sequenciamento das movimentacoes de acordo com o tipo de 	  ³±±
±±³			 ³periodo do gestor e da data de referencia passada.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FXALCGNSeq(cCodUsr,cCodGES,cMoedaSld,cTpMvto,dDtSaldo)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodUsr	- String: Codigo do Usuario.					  ³±±
±±³			 ³cCodGes	- String: Codigo do gestor.						  ³±±
±±³			 ³cMoedaSld	- String: Codigo da Moeda						  ³±±
±±³          ³cTpMvto	- String: Tipo de movimentacao do saldo	          ³±±
±±³          ³			1) Saldo Inicial         				          ³±±
±±³          ³			2) Aprovacao 		    				          ³±±
±±³          ³			3) Estorno de Aprovacao    				          ³±±
±±³          ³			4) Aporte	 		    				          ³±±
±±³          ³			5) Estorno de Aporte	 		    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cSeq	- String: Proxima sequencia para o tipo escolhido.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FXALCGNSeq(cCodUsr,cCodGES,cMoedaSld,cTpMvto,dDtSaldo)

Local cQry		:= ""
Local cDtIni	:= ""
Local cDtFim	:= ""
Local cNextAlias:= GetNextAlias()
Local cSeq		:= ""
Local cInTipo	:= ""

#IFNDEF TOP
	Help(" ",1,"FXALCGNSeqTOP",,STR0001,1,0)	//"Funcionalidade válida somente para ambientes com DBACCESS."
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FXALCGNSeq³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Sequenciamento das movimentacoes de acordo com o tipo de 	  ³±±
±±³			 ³periodo do gestor e da data de referencia passada.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FXAlcPerRet(dData,cCodGes)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dData	- Data: Data do movimento.					  		  ³±±
±±³			 ³cCodGes	- String: Codigo do gestor.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³dRet	- Data: data inicial do perido do gestor.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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