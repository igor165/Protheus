#INCLUDE "CRDA280.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"

Static lMvLjPdvPa	:= FindFunction("LjxBGetPaf") .AND. LjxBGetPaf()[2]	// Indica se eh pdv 
Static aCarFid   	:= {} 													// Numero do Cartao Fidelidade do Cliente/Data Validade/Status.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CRDA280   ³ Autor ³ Leandro Nogueira	    ³ Data ³ 15/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de cartao fidelidade								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpL1:=CRDA280()				 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL					   									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGACRD												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/ 
Function CRDA280()
Local oBrowse

If !GetRpoRelease ("R5")
	Return NIL
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('MBO')
oBrowse:SetDescription(STR0001) // "Cadastro de cartao Fidelidade"
oBrowse:Activate()  		

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³MenuDef	³ Autor ³ Leandro Nogueira	    ³ Data ³ 15/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³MenuDef - MVC												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpA1:=MenuDef()				 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1 = aRotina											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGACRD												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function MenuDef()
Local aRotina 	:= {}


ADD OPTION aRotina TITLE STR0002 	ACTION 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.CRDA280' 	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION 'VIEWDEF.CRDA280' 	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.CRDA280' 	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.CRDA280' 	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 	ACTION 'VIEWDEF.CRDA280' 	OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0008 	ACTION 'VIEWDEF.CRDA280' 	OPERATION 9 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0030	ACTION 'CA280CONSO'  		OPERATION 10 ACCESS 0 //"Consolidar"
ADD OPTION aRotina TITLE STR0031	ACTION 'CA280TRFIL'       OPERATION 11 ACCESS 0 // "Trocar Filial"

Return aRotina



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ModelDef  ³ Autor ³ Leandro Nogueira	    ³ Data ³ 15/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³MVC - Camada de modelo de dados						 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpO1:=ModelDef()			 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1 = oModel											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGACRD												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function ModelDef()  

Local oStruMBO 	:= FWFormStruct( 1, 'MBO') 	// Estrutura do Modelo de Dados
Local oModel	:= MPFormModel ():New('CRDA280MODEL',,{||.T.},{|oModel| CA280COM(oModel)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicoes do modelo de dados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oModel:AddFields( 'MBOMASTER',   , oStruMBO)
oModel:SetDescription(STR0009) 							//"Cadastro de cartão fidelidade"
oModel:GetModel( 'MBOMASTER' ):SetDescription(STR0010)	//"Dados do cartao" 

Return oModel


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ViewDef   ³ Autor ³ Leandro Nogueira	    ³ Data ³ 15/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³MVC - Camada de visualização de dados					 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpO1:=ModelDef()			 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1 = oModel											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGACRD												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function ViewDef()

Local oModel   := FWLoadModel( 'CRDA280' )  	// Modelo de Dados baseado no ModelDef do fonte informado
Local oStruMBO := FWFormStruct( 2, 'MBO' )		// Objeto com a estrutura da View
Local oView    := FWFormView():New()			// Objeto que tem como funcionalidade instanciar os objetos graficos do modelo de dados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicoes do view  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oView:SetModel( oModel )
oView:AddField( 'VIEW_MBO', oStruMBO, 'MBOMASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_MBO', 'TELA' )

Return oView       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ca280Exec ³ Autor ³ Leandro Nogueira	    ³ Data ³ 22/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a funcao desejada de acordo com o ambiente onde a   ³±± 
±±³			 ³e feita a requisicao.										  ³±± 				  
±±³			 ³Se a requisicao de execucao for do Front Loja ou do         ³±± 				  
±±³			 ³SigaLoja PDV Off-Line,a funcao sera executada via WebService³±± 				  
±±³			 ³													          ³±± 				  
±±³			 ³Se a requisicao de execucao for do Sigaloja OnLine          ³±± 				  
±±³			 ³a funcao sera executada local.							  ³±± 				  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=Ca280Exec(cExp1,cExp2,dExp3,nExp4;					  ³±±
±±³			 ³					cExp5,cExp6,cExp7,nExp8,lExp9)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Nome da funcao que será executada					  ³±±
±±³			 ³cExp2 - Numero do cartao fidelidade						  ³±±
±±³			 ³dExp3 - Data de validade da recarga						  ³±±
±±³			 ³nExp4 - Valor da recarga									  ³±±
±±³			 ³cExp5 - Numero do documento								  ³±±
±±³			 ³cExp6 - Serie												  ³±±
±±³			 ³cExp7 - Loja												  ³±±
±±³			 ³cExp8 - Tipo do mmovimento 								  ³±±
±±³			 ³nExp9 - Valor que sera abatido do saldo do cartao (venda)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Ca280Exec (cFunc,		cNumCar, 	dDtValid,	nValor,	;
					cDoc,		cSerie,		cLoja,		cTipo ,	;	
					nSaldoAbat, cCodCli)

Local lRet	:= .F.						//Retorno
Local nX 	:=  0           			//Cotador
Local oSvc 	                			//Objeto do WebService
Local nSaldo:= 0						//Saldo do cartao fidelidade
Local cMoeda:= SuperGetMv("MV_SIMB1")	// Simbolo da moeda principal

Default cFunc		:= ""
Default cNumCar		:= "" 
Default dDtValid	:= "" 
Default nValor		:= 0 
Default cDoc		:= "" 
Default cSerie		:= "" 
Default cLoja		:= "" 
Default cTipo		:= ""
Default cCodCli     := ""
Default nSaldoAbat 	:= 0 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Execucao via WebService para           ³
//³Front Loja ou Sigaloja(PDV Off-Line)   ³                           
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  (nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa)
	
	If !Ca280CkWs () 
		MsgStop(STR0023)//"Web Service para consulta do cartão fidelidade está indisponível !"		
		Return lRet 
	EndIf
	
	
	oSvc      := WSLjCarFid():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
	oSvc:_URL := "http://"+Alltrim(LJGetStation("WSSRV"))+"/LjCarFid.apw"    

	Do Case	
	
	//Validar Cartao Fidelidade		
	Case Upper(cFunc) $ "CA280CART"		
		oSvc:ValCarFid(cNumCar,cEmpAnt,cFilAnt) 		
		lRet:=oSvc:LVALCARFIDRESULT	 		
		If ValType(lRet) <> "U"
			If !lRet
				MsgStop (STR0022)//"Cartão Inválido."
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza o tratamento de erro na comunicacao com o Web Service³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			EndIf
			lRet := .F.
		EndIf
	//Incluir saldo no cartao fiidelidade
	Case Upper(cFunc) $ "CA280ISLD"	 

		oSvc:IncSaldFid(cNumCar,	dDtValid,	nValor,	cDoc,;
						cSerie,		cLoja,		cEmpAnt,cFilAnt)
						
		lRet:=oSvc:lINCSALDFIDRESULT						
		
		If ValType(lRet) == "U"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza o tratamento de erro na comunicacao com o Web Service³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			EndIf
			lRet := .F.
		EndIf
	//Consultar saldo do cartao fiidelidade
	Case Upper(cFunc) $ "CA280CSLD"	 			
		oSvc:ConSaldFid(cNumCar,nValor,cEmpAnt,cFilAnt)
		lRet:=oSvc:lCONSALDFIDRESULT
		If ValType(lRet) <> "U"		
			If !lRet	
				oSvc:CalSaldFid (cNumCar,cEmpAnt,cFilAnt)
				
				If ValType(oSvc:nCALSALDFIDRESULT) <> "U"
					MsgStop (STR0014 +  AllTrim(cMoeda) + " " + AllTrim(TRANSFORM(oSvc:nCALSALDFIDRESULT,'@E 99,999,999.99'))  + STR0015 +  AllTrim(cNumCar) + STR0016,STR0017)//"O Saldo de " # " do cartão fidelidade " # " é insuficiente para completar esta operação !"#"Saldo Insuficiente"  														
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Realiza o tratamento de erro na comunicacao com o Web Service³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSvcError := GetWSCError()
					If Left(cSvcError,9) == "WSCERR048"
							cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
							cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
							Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
					EndIf				
				EndIf
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza o tratamento de erro na comunicacao com o Web Service³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			EndIf
			lRet := .F.
		Endif
	
	//Atualizar saldo do cartao fiidelidade
	Case Upper(cFunc) $ "CA280ASLD"	 
		oSvc:AtuSaldFid(cNumCar,nSaldoAbat,	cDoc,cSerie,;
						cLoja,cEmpAnt,cFilAnt)
		lRet:=oSvc:lATUSALDFIDRESULT
											
		If ValType(lRet) == "U"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza o tratamento de erro na comunicacao com o Web Service³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			EndIf
			lRet := .F.
		EndIf
	//Estornando saldo do cartao fiidelidade
	Case Upper(cFunc) $ "CA280ESLD"	 
		oSvc:EstSaldFid(cNumCar,cDoc,cSerie,cLoja,;
						cTipo,cEmpAnt,cFilAnt)
		lRet:=oSvc:lESTSALDFIDRESULT									

		If ValType(lRet) == "U"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza o tratamento de erro na comunicacao com o Web Service³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			EndIf
			lRet := .F.
		EndIf
	//Consultando Cartao Fidelidade do Cliente
	Case Upper(cFunc) $ "CA280CONCL"	 
		oSvc:ConCartFid(cCodCli,cLoja,cEmpAnt,cFilAnt)
		If ValType(oSvc:oWSCONCARTFIDRESULT:oWSWSFIDITENS) <> "U"
			If Len(oSvc:oWSCONCARTFIDRESULT:oWSWSFIDITENS)> 0	
				aAdd( aCarFid, {	oSvc:oWSCONCARTFIDRESULT:oWSWSFIDITENS[1]:cCartaoFid  ,;
									oSvc:oWSCONCARTFIDRESULT:oWSWSFIDITENS[1]:dDataValFid ,;
									oSvc:oWSCONCARTFIDRESULT:oWSWSFIDITENS[1]:cStatusFid})
	        	lRet := .T.
	        EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza o tratamento de erro na comunicacao com o Web Service³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			EndIf
			lRet := .F.
		EndIf
	OtherWise
		lRet:= .F.
		MsgStop(STR0020)//"Função inválida para validacao de cartão fidelidade"	
	EndCase	                    
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Execucao local para   ³
//³Sigaloja On Line      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	
	Do Case
	
	//Validar Cartao Fidelidade
	Case Upper(cFunc) $ "CA280CART"
		lRet := Ca280Cart (cNumCar)   
		If !lRet
			MsgStop (STR0022)//"Cartão Inválido."
		EndIf
	//Incluir saldo no cartao fiidelidade
	Case Upper(cFunc) $ "CA280ISLD"	 
		lRet := Ca280ISld (cNumCar,	dDtValid,	nValor,	cDoc,;
							cSerie,	cLoja)		
			
	//Consultar saldo do cartao fiidelidade
	Case Upper(cFunc) $ "CA280CSLD"	 
		lRet := Ca280CSld(cNumCar,nValor,@nSaldo)
		If !lRet				
			MsgStop (STR0014 +  AllTrim(cMoeda) + " " + AllTrim(TRANSFORM(nSaldo,'@E 99,999,999.99'))  + STR0015 +  AllTrim(cNumCar) + STR0016,STR0017)//"O Saldo de "#" do cartão fidelidade "#" é insuficiente para completar esta operação !"#"Saldo Insuficiente"
		Endif		
		
	//Atualizar saldo do cartao fiidelidade
	Case Upper(cFunc) $ "CA280ASLD"	 
		lRet := Ca280ASld(cNumCar,nSaldoAbat,cDoc,cSerie,;
							cLoja)	 								 
							
	//Estornar saldo do cartao fiidelidade                                       
	Case Upper(cFunc) $ "CA280ESLD"	 
		lRet := Ca280ESld(cNumCar,cDoc,cSerie,cLoja,;
							cTipo)

	//Consultando Cartao Fidelidade do Cliente
	Case Upper(cFunc) $ "CA280CONCL"	 
		aCarFid := CA280CONCL(cCodCli,cLoja)
		If Len(aCarFid)> 0
			lRet := .T.
		EndIf	 									
	OtherWise
		lRet:= .F.
		MsgStop(STR0020)//"Função inválida para validacao de cartão fidelidade"	
	EndCase
	

EndIf


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ca280Cart ³ Autor ³ Leandro Nogueira	    ³ Data ³ 15/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza as validacoes do cartao fidelidade selecionado      ³±± 
±±³			 ³na tela de recarga (inclusao de saldo).					  ³±± 		  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=Ca280Cart(cExp1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Numero do cartao fidelidade						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Ca280Cart (cNumCar) 
Local lRet		:= .T.     	//Retorno
Local dDataCar 	:= ""      	//Data de validade do cartao
Local cStatus		:= ""		//Status do cartão fidelidade
Local aArea		:= GetArea() //Armazena o alias corrente

Default cNumCar := "" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codigo de barras do cartao informado deve existir na tabela MBO.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MBO")
DbSetOrder(1)
If !DbSeek(xFilial("MBO")+cNumCar)	
	lRet := .F.
Else
	dDataCar:= MBO->MBO_DTVAL 
	cStatus := MBO->MBO_ATIVO			
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A data de validade do cartão escolhido para recarga deve ³
//³ser igual ou superior a data corrente do sistema;        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. dDataCar < dDataBase	
	lRet := .F.
EndIf          
              

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O cartão escolhido para recarga de saldo estar "Ativo" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. cStatus == "2"	
	lRet := .F.
Endif

RestArea(aArea)
                   
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ca280Movim³ Autor ³ Leandro Nogueira	    ³ Data ³ 14/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Incluir movimento de cartao fidelidade (MBN)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=Ca280Movim(cExp1,cExp2,nExp3,cExp4,cExp5,			  ³±±
±±³			 ³					cExp6,cExp7)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cNumCar - Numero do cartao fidelidade						  ³±±
±±³			 ³cItem - Numero do item de saldo do cartao fidelidade.(MBP)  ³±±
±±³			 ³nValor - Valor do saldo inserido no cartão.				  ³±±
±±³			 ³cDoc - Numero do documento								  ³±±
±±³			 ³cSerie - Serie												  ³±±
±±³			 ³cLoja - Codigo da loja									  ³±±
±±³			 ³cTipo - Tipo do movimento (1-Entrada;2-Saida;Estorno Venda; ³±±
±±³			 ³		  Estorno Recarga) 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Ca280Movim (cNumCar,	cItem,	nValor,	cDoc,;
						cSerie,	cLoja,	cTipo) 
					
Local aArea	  	:= GetArea()					// Armazena area atual (alias, order e recno)
Local lRet 		:= .T.                         	//Retorno
Local cSeq		:= Space(TamSx3("MBN_SEQ")[1])	//Item 
Local nSaldoFut := 0							//Novo valor do saldo após o estorno 	

Default cNumCar	:= ""
Default cItem	:= ""
Default	nValor	:= 0 
Default	cDoc	:= ""
Default	cSerie	:= ""
Default	cLoja	:= ""
Default	cTipo	:= ""

Do Case
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo do movimento do cartao fidelidade  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case cTipo == "3"                                                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³3 - ESTORNO DE VENDA PAGA COM CARTAO FIDELIDADE,                      ³
	//³devolve o valor para o registro de saldo correspondente na tabela MBP.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizar tipo do registro da tabela MBN   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	RecLock("MBN",.F.)	
	REPLACE MBN_TIPMOT 	WITH cTipo 		
	MBN->(MsUnlock())
	MBN->(dbCloseArea())
	
	DbSelectArea("MBP")	
	DbSetOrder(3)	
	If DbSeek (xFilial("MBP")+cNumCar+cItem)
		
		//Somar ao valor do saldo atual o valor do movimento estornado.
		nSaldoFut:= MBP->MBP_SALDO + nValor		
		
		RecLock("MBP",.F.)		
		REPLACE MBP_SALDO  WITH nSaldoFut		
		MBP->(MsUnlock())
	EndIf	
	MBP->(dbCloseArea())

Case cTipo == "4"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³4 - EXCLUSAO DE RECARGA DE CARTAO FIDELIDADE, ³
	//³Exclui o registro de movimento (MBN) e de saldo (MBP) correspondentes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DbSelectArea("MBN")	
	DbSetOrder(2)
	
	If DbSeek (xFilial("MBN")+cNumCar+cItem)		
		While MBN->(!Eof()) .AND. MBN->MBN_NUMCAR == cNumCar .AND. MBN->MBN_ITSALD == cItem
			RecLock( "MBN", .F. )
			MBN->(DbDelete())
			MBN->(MsUnLock())						
			MBN->(DbSkip())		
	
			DbSelectArea("MBP")	
			DbSetOrder(3)
			If DbSeek (xFilial("MBP")+cNumCar+cItem)
				While MBP->(!Eof()) .AND. MBP->MBP_NUMCAR == cNumCar .AND. MBP->MBP_ITEM == cItem			
					RecLock( "MBP", .F. )
					MBP->(DbDelete())
					MBP->(MsUnLock())						
					MBP->(DbSkip())		
				End
			Endif						
		End
	EndIf

OtherWise 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obter proximo sequencial do movimento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MBN")
	DbSetOrder(1)
	
	If DbSeek(xFilial("MBN")+cNumCar)
		While AllTrim(MBN->MBN_NUMCAR) == AllTrim(cNumCar)
			cSeq := MBN->MBN_SEQ		                                        
			MBN->(dbSkip())		
		End
	EndIf                     
	MBN->(dbCloseArea())
	cSeq := SomaIt( cSeq )
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravar novo registro de saldo na tabela MBN³                                                        "
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MBN")
	RecLock("MBN",.T.)
	
	REPLACE MBN_FILIAL  WITH xFilial("MBN")
	REPLACE MBN_NUMCAR  WITH cNumCar
	REPLACE MBN_ITSALD  WITH cItem
	REPLACE MBN_DATA  	WITH dDatabase
	REPLACE MBN_DOC 	WITH cDoc
	REPLACE MBN_LOJA	WITH cLoja
	SerieNfId("MBN",1,"MBN_SERIE",dDataBase,LjEspecieNF(),cSerie)
	REPLACE MBN_TIPMOT 	WITH cTipo 
	REPLACE MBN_SEQ 	WITH cSeq
	REPLACE MBN_VALOR 	WITH nValor
	
	MBN->(MsUnlock())
	MBN->(dbCloseArea())
					
EndCase

RestArea (aArea) //Restaura area anterior

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ca280ISld ³ Autor ³ Leandro Nogueira	    ³ Data ³ 13/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Incluir registro de saldo de cartao fidelidade (MBP)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=Ca280ISld(cExp1,dExp2,nExp3,cExp4,	    			  ³±±
±±³			 ³					cExp5,cExp6)		 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Numero do cartao fidelidade						  ³±±
±±³			 ³dExp2 - Data de validade do saldo							  ³±±
±±³			 ³nExp3 - Valor do saldo inserido no cartão.				  ³±±
±±³			 ³cExp4 - Numero do documento								  ³±±
±±³			 ³cExp5 - Serie												  ³±±
±±³			 ³cExp6 - Codigo da loja									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/


Function Ca280ISld (cNumCar,	dDtValid,	nValor,	cDoc,;
					cSerie,		cLoja) 

Local aArea 		:= GetArea() 							// Armazena o alias corrente
Local lRet			:= .F.                             	// Retorno
Local cItem		:= Space(TamSx3("MBP_ITEM")[1])	// Item 

Default cNumCar	:= ""
Default dDtValid:= ""
Default	nValor	:= 0  
Default	cDoc	:= ""
Default	cSerie	:= ""
Default	cLoja	:= ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obter proximo sequencial de item de sado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MBP")
DbOrderNickname("MBPIND3")

If DbSeek(xFilial("MBP")+cNumCar)
	While MBP->MBP_NUMCAR == cNumCar
		cItem := MBP->MBP_ITEM		                                        
		MBP->(dbSkip())		
	End	
EndIf                     

cItem := SomaIt( cItem )
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravar novo registro de saldo na tabela MBP³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("MBP",.T.)

REPLACE MBP_FILIAL  WITH xFilial("MBP")
REPLACE MBP_NUMCAR  WITH cNumCar
REPLACE MBP_ITEM  	WITH cItem
REPLACE MBP_DATA  	WITH dDatabase
REPLACE MBP_DTVAL  	WITH dDtValid
REPLACE MBP_VALOR  	WITH nValor 
REPLACE MBP_SALDO  	WITH nValor
   
MBP->(MsUnlock())

lRet:= Ca280Movim (cNumCar,	cItem,	nValor,cDoc,;
					cSerie,	cLoja,	"1")

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ca280CSld ³ Autor ³ Leandro Nogueira	    ³ Data ³ 20/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta se o cartao fidelidade tem saldo suficiente para   ³±± 
±±³			 ³ser usado como forma de pagto da venda					  ³±± 		  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=Ca280CSld(cExp1,nExp2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Numero do cartao fidelidade						  ³±±
±±³			 ³nExp2 - Valor pago com cartao fidelidade 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Ca280CSld (cNumCar,nValPagto,nSaldo)
Local lRet 		:= .T.						// Retorno
Local nX		:=0                        	// Contador
Local cMoeda	:= SuperGetMv("MV_SIMB1")	// Simbolo da moeda principal

Default cNumCar 	:= ""
Default nValPagto 	:= 0 
Default nSaldo 		:= 0 					// Saldo disponivel do Cartao Fidelidade

nSaldo :=  Ca280Calc(cNumCar)

If nSaldo < nValPagto 
	lRet := .F.
Endif 

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ca280ASld ³ Autor ³ Leandro Nogueira	    ³ Data ³ 21/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o saldo do cartao fidelidade (abatimento) apos o   ³±± 
±±³			 ³o mesmo ter sido utilizado como forma de pagamento na venda.³±± 		  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=Ca280ASld(cExp1,nExp2,cExp3,cExp4,cExp5)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Numero do cartao fidelidade						  ³±±
±±³			 ³nExp2 - Valor que sera abatido do saldo					  ³±±
±±³			 ³cExp3 - Numro do documento								  ³±±
±±³			 ³cExp4 - Serie												  ³±±
±±³			 ³cExp5 - Codigo da loja									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Ca280ASld (cNumCar,nSaldoAbat,	cDoc,cSerie,;
					cLoja)                    
					
Local nSaldoAnt		:= 0 			//Saldo anterior da recarga 
Local nSaltoFut 	:= 0			//Saldo Futuro
Local nSaldoRest 	:= nSaldoAbat	//Saldo restante a ser abatido do proximo registro de saldo
Local nValorMov     := 0			//Valor do movimento que será gravado na tabela MBN
Local aSaldosFid	:=	{}			//Array que armazenara os saldos válidos para abatimento do cartao fidelidade informado
Local n				:= 0			//Contador    
Local lRet			:= .T.         	//Retorno

Default cNumCar		:= ""
Default nSaldoAbat  := 0
Default cDoc        := "" 
Default cSerie     	:= "" 
Default cLoja		:= "" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aSaldosFid ³
//³                              ³
//³1- Numero do cartao fidelidade³
//³2- Numero do item de saldo    ³
//³3- Valor do saldo             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MBP")
DbOrderNickname("MBPIND2")

If DbSeek(xFilial("MBP")+cNumCar)
	While !MBP->(Eof()) .AND. AllTrim(MBP->MBP_NUMCAR) == AllTrim(cNumCar) .AND. MBP->MBP_DTVAL >= dDataBase		
		If  (MBP->MBP_SALDO > 0 , Aadd(aSaldosFid,{MBP->MBP_NUMCAR,MBP->MBP_ITEM,MBP->MBP_SALDO}),) 
		MBP->(DbSkip())	                           
	End                
EndIf
MBP->(dbCloseArea())

For n:= 1 to Len(aSaldosFid)
	If nSaldoRest > 0
		nSaldoAnt:= aSaldosFid [n][3]			
		nSaltoFut:= aSaldosFid [n][3]
	 
		If nSaldoAnt < nSaldoRest
			nSaldoRest 	:= nSaldoAbat - nSaldoAnt
			nSaltoFut	:= nSaldoAnt -  nSaldoAbat + nSaldoRest
			nValorMov	:= nSaldoAbat - nSaldoRest		
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Saldo Futuro = Saldo Anterior - Saldo Abatido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			nSaltoFut 	:= nSaldoAnt -  nSaldoRest
			nValorMov	:= nSaldoRest
			nSaldoRest	:= 0 
		Endif 		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizar saldo na tabela MBP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		DbSelectArea("MBP")
		DbSetOrder(3)
		If DbSeek(xFilial("MBP")+aSaldosFid [n][1]+aSaldosFid [n][2])
			RecLock("MBP",.F.)
			REPLACE MBP_SALDO WITH nSaltoFut			
			MsUnlock()
			MBP->(dbCloseArea())					
			
			//Inserir movimento na tabela MBN
			Ca280Movim(cNumCar,	aSaldosFid [n][2],nValorMov,cDoc,;
						cSerie,	cLoja,	"2")
		EndIf
	EndIf 	
		
Next n	
	
lRet:= .T.
			
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ca280ESld ³ Autor ³ Leandro Nogueira	    ³ Data ³ 27/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Estorna o movimento e atualiza o saldo do cartao fidelidade ³±± 
±±³			 ³quando a venda for cancelada.								  ³±± 		  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=Ca280ESld(cExp1,cExp2,cExp3,cExp4,cExp5)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Numero do cartao fidelidade						  ³±±
±±³			 ³cExp2 - Numero do documento								  ³±±
±±³			 ³cExp3 - Serie												  ³±±
±±³			 ³cExp4 - Loja												  ³±±
±±³			 ³cExp5 - Tipo do movimento									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Ca280ESld (cNumCar,cDoc,cSerie,cLoja,;
					cTipo)                    
					
Local aArea	  		:= GetArea()	//Armazena area atual (alias, order e recno)
Local lRet			:= .F.         	//Retorno
Local nRecNo		:= 	0			//Numero do RECNO anterior

Default cNumCar		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cLoja		:= ""
Default cTipo		:= ""

DbSelectArea("MBN")
DbSetOrder(3)

If DbSeek (xFilial("MBN")+cNumCar+cDoc+cSerie)
	While (MBN->MBN_NUMCAR == cNumCar .AND. MBN->MBN_DOC == cDoc .AND. MBN->MBN_SERIE == cSerie)
		nRecNo:= MBN->(recno())
		If MBN->MBN_TIPMOT <> "3" .AND. MBN->MBN_TIPMOT <> "4"		  
	    	lRet:= Ca280Movim(cNumCar,	MBN->MBN_ITSALD	,	MBN->MBN_VALOR,		cDoc,;
	    						cSerie,	cLoja,				cTipo)					   		    
	  	EndIf
	  	MBN->(DbGoto(nRecNo))
	    MBN->(DbSkip())
    End
EndIf

RestArea(aArea)
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ca280Calc ³ Autor ³ Leandro Nogueira	    ³ Data ³ 20/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o saldo disponivel do cartao fidelidade 			  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=Ca280Calc(cExp1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Numero do cartao fidelidade						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Ca280Calc(cNumCar)
Local aArea 	:= GetArea()	//Armazena o alias corrente 
Local nSaldo	:= 0       	//Saldo disponivel para o cartao

Default cNumCar	:= ""      //Numero do Cartao

DbSelectArea("MBP")
DbOrderNickname("MBPIND2")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consultar saldo do cartao de fidelidade na tabela MBP,³
//³considerando que a data de validade do saldo deve ser ³
//³maior ou igual a data corrente do sistema.            ³
//³A soma do valor de saldo dos registros encontrados    ³
//³sera o valor de saldo disponivel para utilizacao      ³
//³como forma de pagamento da venda.                     ³
//³                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If DbSeek(xFilial("MBP")+cNumCar)
	While !MBP->(Eof()) .AND. AllTrim(MBP->MBP_NUMCAR) == AllTrim(cNumCar)		
		If MBP->MBP_DTVAL >= dDataBase
			nSaldo+=MBP->MBP_SALDO			
		EndIf
		MBP->(DbSkip())			   		
	End
Endif

RestArea(aArea)

Return nSaldo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ca280CkWs ³ Autor ³ Leandro Nogueira	    ³ Data ³ 10/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica disponibilidade do WebService LJCARFID 			  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=Ca280CkWs()										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Ca280CkWs()
Static lRet := .F. 	//Retorno
Static oSvc			//Objeto do WebService

oSvc      := WSLjCarFid():New()
iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
oSvc:_URL := "http://"+Alltrim(LJGetStation("WSSRV"))+"/LjCarFid.apw"

If oSvc:Conecta("")
	lRet := .T.
Endif

oSvc := NIL

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CA280COM ³ Autor ³ Ricardo Lovrenovic    ³ Data ³ 25/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica dados SA1 e Insere Cod. Cart. Fidelidade no Cliente³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1 := CA280COM (oModel)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³True 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CRDA280COM									              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function CA280COM (oModel)
Local nOperation 	:= 0 // Numero da Operação.

Default oModel := Nil


If ValType(oModel) <> "U"
	nOperation 	:= oModel:GetOperation() 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza Gravação na Tabela SA1, pegando o código do       ³
//³Cliente Digitado na Tela de Inclusão de Cartões Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FWFormCommit( oModel ) 	
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1") + oModel:GetValue( 'MBOMASTER', 'MBO_CODCLI'))
		RecLock("SA1",.F.)
		Replace A1_CODFID with oModel:GetValue( 'MBOMASTER', 'MBO_CODBAR')
    	SA1->(MsUnlock())
    EndIf
EndIf

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CA280CONCL³ Autor ³ Ricardo Lovrenovic    ³ Data ³ 03/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta o Numero do Cartao Fidelidade do Cliente			  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=CA280CONCL(cExp1,cExp2)    						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Numero do cartao fidelidade						  ³±±
±±³			 ³cExp2	- Codigo da Loja				  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cExp3 - Codigo Fidelidade 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function CA280CONCL(cCodCli,cLoja)

Local aArea      	:= GetArea() // Grava o estado das Tabelas
Local cCarFid		:= ""        // Codigo Cartao Fidelidade
Local cStatus       := ""        // Status Ativo ou Inativo do Cartao
Local dDataCar      := ""        // Data de Validade do Cartao
Local aCliCarFid    := {}        // Array com infos do Cartao

Default cCodCli	:= ""
Default cLoja   := ""

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1")+cCodCli+cLoja)
	cCarFid := SA1->A1_CODFID
	If !Empty(cCarFid)     
		DbSelectArea("MBO")
		DbSetOrder(1)
		If DbSeek(xFilial("MBO")+cCarFid)	
			dDataCar:= MBO->MBO_DTVAL 
			cStatus := MBO->MBO_ATIVO			
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona informacoes pesquisadas sobre o Cartao ³
		//³na Tabela MBO de cadastro dos Cartoes fidelidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aCliCarFid, {cCarFid,dDataCar,cStatus} )
	EndIf                                                                        
	
Endif

RestArea( aArea )	

Return aCliCarFid

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA280GetArº Autor ³	Vendas & Crm     º Data ³  10/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Transporta o valor da variavel aCarFid.				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³      	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CA280GetAr()
Return aCarFid


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | CA280Conso º Autor ³	  Ricardo.Bueno    º Data ³  14/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe tela dos Cartoes selecionados para consolidacao       	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCarts: Array com Cartoes a serem exibidos para Consolidar   º±±
±±º          ³ em um novo Cartao e excluir os antigos    			        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet		   									              	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA280                                                     	º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CA280CONSO()

Local aCarts    := {}                                                       // Cartoes
Local aArea		:= GetArea()												// Array de Retorno 
Local cCartFid	:= ""                                                      // Código Cartão Fidelidade
Local cCliente	:= ""                                                      // Codigo do cliente
Local cLoja		:= ""                                                      // Codigo da Loja
Local cFilTab   := ""                                                      // Filial
Local dValiCart := ""                                                      // Validade do Cartão
Local cHistCons := ""                                                      // Historico da Consolidação do Cartao
Local nValor	:=  0                                                      // Valores
Local nVSaldo	:=  0                                                      // Saldos
Local nX		:=  0                                                      // Contador
Local nVlrSaldo :=  0                                                      // Valor Saldo Manipulado
Local nOper     :=  0                                                      // Retorno de Numero da Operaçao
Local lOkNo		:= .F.                                                     // Ok/No
Local lRet		:= .F.                                                     // Retorno
Local lIncSaNeg := .T.                                                     // Incluir Saldo Negativo
Local cPicture 	:= PesqPict("SLR","LR_VLRITEM") 							// Picture

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza Varredura na Tabela MBO, para analisar todos os³
//³Cartões Fidelidade que estão Cadastrados e apenas      ³
//³adicionar no Array os que possuem Saldo, positivo.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MBO")
While !Eof("MBO")
	cFilTab   := MBO->MBO_FILIAL
	cNumCar   := MBO->MBO_CODBAR
	nVSaldo   := TRANSFORM(CA280CALC(cNumCar), cPicture)
	cCliente  := MBO->MBO_CODCLI
	cLoja	  := MBO->MBO_LOJA
	dValiCart := MBO->MBO_DTVAL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabelas [MBP] e [MBO] inserindo as informacoes no Array aCarts dos                  ³
	//³Cartoes Fidelidade para exibir e criar opcoes de Selecionar e 					   ³
	//³consolidar os Cartoes.															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF	!EMPTY(nVSaldo) 
		AAdd(aCarts, {lOkNo,cNumCar,cCliente,cLoja,dValiCart,nVSaldo,cFilTab} )
	EndIf 
	//
	MBO->(DbSelectArea("MBO"))
	MBO->(DbSkip())
End                                                                        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CA280TELA													    ³
//³ Função que monta o GRID a partir do array passado e exibe       ³
//³ os cartoes cadastrados na tabela MBO para que sejam selecionados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetorno := CA280TELA(aCarts)

If (Len(aRetorno) > 1) 
	For nX := 1 To Len(aRetorno)
		nVlrSaldo := nVlrSaldo +Val(StrTran(StrTran(aRetorno[nX][1][6],".",""),",","."))
	Next nX
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a abertura da Tela de Inclusao de Cartao Fidelidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nOper := FWExecView(STR0033,'CRDA280', MODEL_OPERATION_INSERT, , { || .T.},,30)

    If (nOper == 0)
 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclusao do Saldo total dos Cartoes selecionados no Cartao³
		//³que acabou de ser cadastrado e registrado na [MBO]        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("MBO")
		cHistCons := (STR0034+MBO_CODBAR)
		lIncSaldo := Ca280Exec ( "Ca280ISld",MBO_CODBAR, MBO->MBO_DTVAL,nVlrSaldo,	;
										 Nil, 		Nil,   MBO->MBO_LOJA,     Nil ,	;	
				   	    				 Nil, 		Nil)
        If lIncSaldo
			For nX := 1 To Len(aRetorno)
				cCartDel := aRetorno[nX][1][2]
				DbSelectArea("MBO")
				DbSetOrder(1)
				If DbSeek(xFilial("MBO")+cCartDel)	
  					nVSaldo   := CA280CALC(MBO_CODBAR)
                   	lIncSaNeg := Ca280Exec ( "Ca280ISld",MBO_CODBAR, MBO->MBO_DTVAL,	nVSaldo*(-1),	;
										Nil, 		Nil, MBO->MBO_LOJA,  Nil ,	;	
				   	  					Nil, 		Nil)
				    If lIncSaNeg
				    	RecLock("MBO",.F.)
						Replace MBO_ATIVO  WITH "2"
    					Replace MBO_COHIST WITH cHistCons
    					MBO->(MsUnlock())
				        lRet := .T.
				  	EndIf
				EndIf
			Next nX
        EndIf
    Else
    	MsgAlert(STR0041) // Novo Cartao Nao Cadastrado, Reiniciar o Processo de Consolidacao! //verificar! 															
    EndIf
Else
	MsgAlert(STR0040) // Selecionar mais de um Cartao para realizar a Consolidacao! //verificar! 															
EndIf    	

If lRet
	MsgAlert(STR0039) // Processo de Consolidacao Concluido com Sucesso! //verificar! 															
EndIf

RestArea (aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | CA280TRFIL º Autor ³	  Ricardo.Bueno    º Data ³  31/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao troca filial de Cartao Selecionado                	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCarts: Array com Cartoes a serem exibidos para Consolidar   º±±
±±º          ³ em um novo Cartao e excluir os antigos    			        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil		  									              	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA280                                                     	º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CA280TRFIL()

Local aArea	  	:= GetArea()					// Armazena area atual (alias, order e recno)
Local oFil 	    := Nil          				// Objeto
Local oWiCndEtq	:= Nil							// Objeto para mostrar codigo da filial.
Local aRetCarts := {}							// Array de Retorno dos Cartoes Selecionados
Local aCarts    := {} 							// Array dos Cartoes Selecionados no Grid
Local cFil   	:= Space(FWGETTAMFILIAL)		// Filial que foi selecionada na tela.
Local cNumCar	:= ""           				// Numero do Cartão
Local cCliente	:= ""           				// Cliente
Local cLoja		:= ""           				// Loja
Local dValiCart	:= ""           				// Validade do Cartão
Local cFilTab	:= ""           				// Filial
Local nXt 		:= 0            				// Contador
Local nVSaldo	:= 0            				// Valor do Saldo
Local lOkNo		:= .F.          				// Ok/No
Local cPicture 	:= PesqPict("SLR","LR_VLRITEM")// Picture 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica.                                             ³
//³Caso CAMODOEXCL for True, significa que as tabelas MBO³
//³MBP e MBN estão em modo exclusivo e podem receber o   ³
//³registro de filiais do sistema.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CaModoExcl()
	DbSelectArea("MBO")
	DbSetOrder(1)
	While !Eof("MBO")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza Varredura na Tabela MBO, para analisar todos os³
		//³Cartões Fidelidade que estão Cadastrados               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilTab   := MBO->MBO_FILIAL
		cNumCar   := MBO->MBO_CODBAR
 		nVSaldo   := TRANSFORM(CA280CALC(cNumCar), cPicture)
		cCliente  := MBO->MBO_CODCLI
		cLoja	  := MBO->MBO_LOJA
		dValiCart := MBO->MBO_DTVAL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tabelas [MBP] e [MBO] inserindo as informacoes no Array aCarts dos                  ³
		//³Cartoes Fidelidade para exibir e criar opcoes de Selecionar e 					   ³
		//³consolidar os Cartoes.															   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aCarts, {lOkNo,cNumCar,cCliente,cLoja,dValiCart,nVSaldo,cFilTab} )
		MBO->(DbSelectArea("MBO"))
		MBO->(DbSkip())
	End
	
	If Len(aCarts) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe.                                                  ³
		//³Tela com os Cartões Fidelidade Cadastrados na Tabela MBO³
		//³são exibidos para que o usuário Selecione os que serão  ³
		//³manipulados                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetCarts := CA280TELA(aCarts)
	EndIf
	
	If Len(aRetCarts) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta tela de consulta das Filiais ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oWindEtq FROM 57,160 TO 200,200 TITLE STR0036 PIXEL OF GetWndDefault()
		
		@ 04, 05 TO 28, 56 LABEL STR0029 OF oWindEtq PIXEL
		@ 13, 10 MSGET oFil VAR cFil F3 ("XM0") OF oWindEtq PIXEL Valid ExistCpo("SM0",cEmpAnt+cFil)
		DEFINE SBUTTON FROM 050,005 TYPE 1 ACTION (oWindEtq:End()) ENABLE OF oWindEtq 						//"Ok"
		DEFINE SBUTTON FROM 050,035 TYPE 2 ACTION (oWiCndEtq:End()) ENABLE OF oWindEtq //"Cancelar"
		
		ACTIVATE MSDIALOG oWindEtq CENTER
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o usuário tenha escolhido uma Filial, continua³
		//³a rotina de mudança de Filiais.                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !EMPTY(cFil)
			If Len(aRetCarts) > 0
				For nXt := 1 To Len(aRetCarts)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tabela de Cadastro de Cartoes.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("MBO")
					DbSetOrder(1)
					If DbSeek(xFilial("MBO")+aRetCarts[nXt][1][2])
						RecLock("MBO",.F.)
						Replace MBO_FILIAL  WITH cFil
						MBO->(MsUnlock())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Tabela de Movimentação de Cartoes³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("MBN")
						DbSetOrder(1)
						If DbSeek(xFilial("MBN")+aRetCarts[nXt][1][2])
							While MBN->MBN_NUMCAR == (aRetCarts[nXt][1][2])
								RecLock("MBN",.F.)
								Replace MBN_FILIAL  WITH cFil
								MBN->(MsUnlock())
								MBN->(dbSkip())		
							End
						EndIf                     
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Tabela de Saldo de Cartoes		³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("MBP")
						DbSetOrder(1)
						If DbSeek(xFilial("MBP")+aRetCarts[nXt][1][2])
							While MBP->MBP_NUMCAR == (aRetCarts[nXt][1][2])
								RecLock("MBP",.F.)
								Replace MBP_FILIAL  WITH cFil
								MBP->(MsUnlock())
								MBP->(dbSkip())		
							End
						EndIf                     
					EndIf
				Next nXt
			EndIf
		EndIf
	EndIf
Else
	MsgAlert(STR0037,STR0038) //Funcionalidade somente ativa em modo exclusivo das tabelas MBO, MBP e MBN.															
EndIf

RestArea (aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | CA280RETGR º Autor ³	  Ricardo.Bueno    º Data ³  22/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Separa os itens selecionados como True e retorna Array     	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCarts: Array com Cartoes a serem exibidos  			        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ aCodProd    									              	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA280                                                     	º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CA280RETGR(aSelGrid)
Local aCodProd 	:= {}            // Array de produtos do retorno
Local nCont    	:= 1             // Contador
                                                 
Default aSelGrid  := {}			 // Array com dados trazidos para manipular.
                                                                                                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina que verifica os itens do Array                       ³
//³Caso o item seja True, significa que foi selecionado no Grid³
//³Separa os itens selecionados como True e retorna Array.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCont := 1 To Len(aSelGrid)
	If aSelGrid[nCont][1] == .T.
		AADD(aCodProd,{aSelGrid[nCont]})
	EndIf
Next nCont

Return aCodProd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | CA280TELA  º Autor ³	  Ricardo.Bueno    º Data ³  01/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe GRID para selecionar os Itens							º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³  aArray :=													º±±
±±º			 ³	cTipo  :=			        								º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ARRAY    									              	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA280                                                     	º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CA280TELA(aArray)

Local oDlg      := Nil 																// Objeto de Tela. 
Local olstResul := Nil																// Objeto de Tela. 
Local obtnInser := Nil 																// Objeto de Tela. 
Local oOK 		:= LoadBitmap(GetResources(),"LBOK") 								// Botoes de selecao 
Local oNO 		:= LoadBitmap(GetResources(),"LBNO") 								// Botoes de selecao
Local aHeaders 	:= {"  ",STR0024,STR0025,STR0026,STR0027,STR0028,STR0029}   		// Labels do cabecalho do grid.
Local aTamHead 	:= {10,52,52,52,52,52,52}                                          // Tamanho das linhas do cabeçalho.
Local aRetorno  := {}																// Array de retorno com os itens selecionados.

Default aArray	:= {}                                                               // Array enviado com os itens para exibiçao na tela.

If Len(aArray)> 0
	DEFINE MSDIALOG oDlg TITLE STR0033 FROM 80,100 TO 500,830 PIXEL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Grid de Resultado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	olstResul := TCBrowse():New( 10,20,330,180, ,aHeaders,aTamHead,;
	oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	olstResul:SetArray(aArray)
	olstResul:bLine := {||{ If(aArray[olstResul:nAt,01],oOk,oNo),aArray[olstResul:nAt,02],aArray[olstResul:nAt,03],(aArray[olstResul:nAt,04]),(aArray[olstResul:nAt,05]),(aArray[olstResul:nAt,06]),(aArray[olstResul:nAt,07])} }
	olstResul:bLDblClick := {|| aArray[olstResul:nAt][1] := !aArray[olstResul:nAt][1],olstResul:DrawSelect(),olstResul:Refresh() }
	obtnInser  := TButton():New( 195,315,STR0035,oDlg,{|| aRetorno := CA280RETGR(aArray), oDlg:End() },; //"OK"
	37,12,,,.F.,.T.,.F.,,.F.,,,.F. )
    
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	MsgAlert(STR0040) // alerta o usuario														
EndIf
obtnInser  := Nil
olstResul  := Nil
oDlg       := Nil

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | CaModoExcl º Autor ³	  Ricardo.Bueno    º Data ³  05/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³	Verifica o Modo Exclusivo das Tabelas para realizar o 		º±±
±±º			 ³	controle de Cartoes por Filiais						        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nil 			        										º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet											              	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA280                                                     	º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CaModoExcl()
Local lRet 	:= .F.
Local aArea	:= GetArea()

SX2->(DbSetOrder(1))
If SX2->(DbSeek("MBO"))
   lRet  := ( FWModeAccess("MBO",3) == "E")
EndIf

If lRet .AND. SX2->(DbSeek("MBP")) 
   lRet  := ( FWModeAccess("MBP",3) == "E")
EndIf

If lRet .AND. SX2->(DbSeek("MBN"))
   lRet  := ( FWModeAccess("MBN",3) == "E")
EndIf

RestArea (aArea) 
Return lRet
