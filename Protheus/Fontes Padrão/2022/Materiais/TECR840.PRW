#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TECR840.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} TECR840
 Rotina de disparo de emails de alertas atraves do Job

@author	Servi�os
@since		16/09/2013
@return	Nil
/*/
//-------------------------------------------------------------------
Function TECR840( aParams )

RpcSetType( 3 ) // Executa sem consumir licen�a 
RpcSetEnv( aParams[1],aParams[2], , , "TEC")

conout(STR0001) // Iniciando job para disparo de alertas...

At840RSndEml()

conout(STR0002) // Finalizado job de disparo de alertas...
	
RpcClearEnv()

Return(Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} At840RSndEml
Envio de mails de alertas dos eventos atraves do Job

@author	Servi�os
@sample	At840RSndEml()
@since		16/09/2013
@return	Nil
/*/
//-------------------------------------------------------------------			      
Static Function At840RSndEml() 

Local oServer  
Local oMessage
Local aAreaTEQ
Local nI		  
Local nJ
Local nErr      	:= 0
Local aEmails		:= {}								// LISTA DE EMAILS PARA ENVIO DOS ALERTAS
Local aCmpVld		:= {}								// LISTA DE CAMPOS DA REGRA
Local nSMTPPort 	:= GetNewPar("MV_PORSMTP",25)	// PORTA SMTP
Local cSMTPAddr 	:= GetNewPar("MV_RELSERV","")	// ENDERECO SMTP
Local cUser     	:= GetNewPar("MV_RELAUSR","")	// USUARIO PARA AUTENTICACAO SMTP
Local cPass     	:= GetNewPar("MV_RELAPSW","")	// SENHA PARA AUTENTICA SMTP
Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// VERIFICAR A NECESSIDADE DE AUTENTICACAO
Local nSMTPTime 	:= GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO
Local lSSL 		:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
Local lTLS 		:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
Local cFrom 		:= GetNewPar("MV_RELFROM","") 	// EMAIL REMENTE DOS ALERTAS
Local cNomeCmp	:= ""
Local cMascCmp 	:= ""
Local cTipCmp  	:= ""
Local cNomeRet	:= ""
Local cMascRet 	:= ""
Local cTipRet  	:= ""			
Local cNomeTab	:= ""
Local cCmpEml1	:= ""
Local cCmpEml2	:= ""
Local aDesLog		:= {}

// Verificar autenticacao e retira o conteudo apos o @
If lAutentica .And. At("@",cUser)>0
	cUser := Subs(cUser,1,At("@",cUser)-1)
EndIf

// Objeto de Email
oServer := tMailManager():New()

// Usa SSL, TLS ou nenhum na inicializacao
If lSSL
	oServer:SetUseSSL(lSSL)		
ElseIf lTLS
	oServer:SetUseTLS(lTLS)	
Endif

// Inicializacao do objeto de Email
nErr := oServer:init("",cSMTPAddr,cUser,cPass,,nSMTPPort)
If nErr <> 0	
	CoNout(STR0003 + oServer:getErrorString(nErr)) // Falha ao conectar: 	
	Return(.F.)
Endif

// Define o Timeout SMTP
If oServer:SetSMTPTimeout(nSMTPTime) != 0
	CoNout(STR0004) // Falha ao definir timeout
	Return(.F.)
EndIf

// Conecta ao servidor
nErr := oServer:smtpConnect()
If nErr <> 0	
	CoNout(STR0003 + oServer:getErrorString(nErr)) // Falha ao conectar:		
	oServer:SMTPDisconnect()
	Return(.F.)
EndIf

// Realiza autenticacao no servidor
If lAutentica
	nErr := oServer:smtpAuth(cUser, cPass)
	If nErr <> 0		
		CoNout(STR0005 + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect()
		Return(.F.)
	EndIf
EndIf	

// Cria uma nova mensagem (TMailMessage)
oMessage := tMailMessage():new()
oMessage:clear()        

// Verifica��o de todos os eventos cadastrados

dbSelectArea("TEQ")
TEQ->(dbSetOrder(1))
TEQ->(dbGoTop())

While TEQ->(!Eof())
		
	If TEQ->TEQ_STATUS == "1" // Verifica se o evento esta ativo 
	
		aCmpVld  := At840RVldEve("TEQ") // Carrega os campos que obedeceram a regra				
			
		If Len(aCmpVld) > 0		
			
			cNomeCmp := Posicione("SX3", 2, TEQ->TEQ_CAMPO	,"X3Titulo()"	)
			cMascCmp := Posicione("SX3", 2, TEQ->TEQ_CAMPO	,"X3_PICTURE"	)
			cTipCmp  := Posicione("SX3", 2, TEQ->TEQ_CAMPO	,"X3_TIPO"		)	
			
			cNomeRet := Posicione("SX3", 2, TEQ->TEQ_CPORET	,"X3Titulo()"	)
			cMascRet := Posicione("SX3", 2, TEQ->TEQ_CPORET	,"X3_PICTURE"	)
			cTipRet  := Posicione("SX3", 2, TEQ->TEQ_CPORET	,"X3_TIPO"		)
							
			cNomeTab := Posicione("SX2", 1, TEQ->TEQ_TABELA	, "X2Nome()"	)		
		
			aEmails := At840REmlEve(TEQ->TEQ_CODEVE) // Carrega a lista de emails a serem enviados			
				
			For nJ := 1 To Len(aCmpVld)			
						
				aDesLog := {}
				
				For nI := 1 To Len(aEmails)				
																		
					cMensagem := "<b>" + STR0006 + "</b>" // EVENTO DE ALERTAS AUTOMATICO TOTVS-PROTHEUS, FAVOR NAO RESPONDER
					cMensagem += "<br><br>"				
										 
					If !Empty(cMascCmp)					
						cCmpEml1 := Transform(aCmpVld[nJ][1], cMascCmp)
					ElseIf 	cTipCmp == "D"
						cCmpEml1 := Right(	aCmpVld[nJ][1],2) 	+ "/" + ;
										Substr(aCmpVld[nJ][1],5,2) 	+ "/" + ;
										Left(	aCmpVld[nJ][1],4)
					ElseIf 	cTipCmp == "N"
						cCmpEml1 := AllTrim(Str(aCmpVld[nJ][1]))
					Else 
						cCmpEml1 := AllTrim(aCmpVld[nJ][1])												
					EndIf
					
					If !Empty(cMascRet)
						cCmpEml2 := Transform(aCmpVld[nJ][2], cMascRet)
					ElseIf 	cTipRet == "D"
						cCmpEml2 := Right(	aCmpVld[nJ][2],2) 	+ "/" + ;
										Substr(aCmpVld[nJ][2],5,2) 	+ "/" + ;
										Left(	aCmpVld[nJ][2],4)
					ElseIf 	cTipRet == "N"
						cCmpEml2 := AllTrim(Str(aCmpVld[nJ][2]))
					Else 
						cCmpEml2 := AllTrim(aCmpVld[nJ][2])																
					EndIf		
									
					If TEQ->TEQ_INFEVE == "1"	// Inclusao no texto do emails infs. do evento											
						cMensagem += STR0007 + "<b>" + AllTrim(cNomeTab) + "</b>" // Evento disparado para 
						cMensagem += "<br><br>"						
						cMensagem += STR0008 // Verificar a ocorrencia : 
						cMensagem += "<br>"
						cMensagem += "- " + cNomeRet + " = " + cCmpEml2
						cMensagem += "<br>" 
						cMensagem += "- " + cNomeCmp + " = " + cCmpEml1						  	
						cMensagem += "<br><br>"  	
					EndIF
			
					cMensagem += TEQ->TEQ_TXTEML				
				
					// Dados da mensagem		
					oMessage:cFrom	:= cFrom
					oMessage:cTo     	:= aEmails[nI][2]		
					oMessage:cSubject	:= TEQ->TEQ_TITEML
					oMessage:cBody   	:= cMensagem
					
					// Envia a mensagem
					nErr := oMessage:send(oServer)
					
					aAdd(aDesLog, {aEmails[nI][1],;
									 aEmails[nI][2],;
									 Iif(nErr <> 0, "2", "1")} )				
					
				Next nI
								
				aAreaTEQ := TEQ->(GetArea())								
				At860GrvCab( {{ TEQ->TEQ_CODEVE,;	// Codigo do Evento
								TEQ->TEQ_TABELA + "->" + TEQ->TEQ_CAMPO + ;
								Iif(TEQ->TEQ_OPEMAT == "1", "+"	,;			
			  					Iif(TEQ->TEQ_OPEMAT == "2", "-"	,;			
			  					Iif(TEQ->TEQ_OPEMAT == "3", "*"	,;
			  					Iif(TEQ->TEQ_OPEMAT == "4", "/","")))) + ;
			  					AllTrim(Str(TEQ->TEQ_PARAME)) + ;
			  					Iif(TEQ->TEQ_TPOORE == "1", " > "	,;			
			  					Iif(TEQ->TEQ_TPOORE == "2", " < "	,;			
			  					Iif(TEQ->TEQ_TPOORE == "3", " = "	,;			
			  					Iif(TEQ->TEQ_TPOORE == "4", " >= ",;			
			  					Iif(TEQ->TEQ_TPOORE == "5", " <= ",""))))) + ;
			  					Iif(TEQ->TEQ_CONDIC == "1", STR0009,; // Data Hoje
			  					Iif(TEQ->TEQ_CONDIC == "2",	AllTrim(Str(TEQ->TEQ_VLRRES)),"")),;//Senten�a da regra
			  					aCmpVld[nJ][3],;	// X2_UNICO da tabela
			  					aCmpVld[nJ][1],;	// Valor econtrado
			  					aCmpVld[nJ][2] }},; // Valor retornado
			  					aDesLog )				// lista de destinatarios
			  	RestArea(aAreaTEQ)
								
			Next nJ
			
		EndIf	
			
	EndIf		
		
	TEQ->(dbSkip())
	
EndDo

TEQ->(dbCloseArea())

// Desconecta do Servidor
oServer:smtpDisconnect()

Return(.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} At840REmlEve
Carrega a lista de emails a serem enviados do evento

@author	Servi�os
@since		17/09/2013
@sample	At840REmlEve(TEQ->TEQ_CODEVE)
@param		cCodEvento - Codigo do evento que deseja carregar a lista
@return	Nil
/*/
//-------------------------------------------------------------------		      	  
Function At840REmlEve(cCodEvento)

Local aEmails 	  	:= {}
Local cAliasTEY 	:= GetNextAlias()

BeginSQL Alias cAliasTEY

SELECT TEY.TEY_CODDES, TEP.TEP_EMAIL
FROM %Table:TEY% TEY, %Table:TEP% TEP 
WHERE	TEY.TEY_FILIAL = %xFilial:TEY% 		AND
	   	TEY.TEY_CODEVE = %Exp:cCodEvento% 	AND 
		TEY.%NotDel% 							AND
		TEP.TEP_FILIAL = %xFilial:TEP%		AND 
		TEY.TEY_CODDES = TEP.TEP_CODDES		 		

EndSQL

(cAliasTEY)->(dbGoTop())

While (cAliasTEY)->(!Eof())
	aAdd(aEmails, {(cAliasTEY)->TEY_CODDES, (cAliasTEY)->TEP_EMAIL})
	(cAliasTEY)->(dbSkip())
EndDo

Return(aEmails)


//-------------------------------------------------------------------
/*/{Protheus.doc} At840RVldEve
Verifica a valida��o da regra do evento cadastrado

@author	Servi�os
@since		17/09/2013
@sample	At840RVldEve("TEQ")
@param		cAlias - Alias para verfica��o da regra do evento
@return	Nil
/*/
//-------------------------------------------------------------------		      	  
Function At840RVldEve(cAlias)

Local aArea		:= GetArea()
Local cTabela		:= (cAlias)->TEQ_TABELA
Local cCampo		:= (cAlias)->TEQ_CAMPO
Local cCampRet		:= (cAlias)->TEQ_CPORET 	
Local cAliasUI		:= GetNextAlias()
Local cWhere		:= "%%"
Local cCmp1		:= "%%"
Local cCmp2		:= "%%"
Local cTab 		:= "%%"
Local cValCond	:= ""
Local cUnico		:= ""
Local aRetorno		:= {}	// Retorno dos campos que obedeceram a regra
				
//Operador Logico
Local cOpeLog := 	Iif((cAlias)->TEQ_TPOORE == "1", ">"	,;			// 1=Maior
			  		Iif((cAlias)->TEQ_TPOORE == "2", "<"	,;			// 2=Menor
			  		Iif((cAlias)->TEQ_TPOORE == "3", "="	,;			// 3=Igual
			  		Iif((cAlias)->TEQ_TPOORE == "4", ">="	,;			// 4=Maior Igual
			  		Iif((cAlias)->TEQ_TPOORE == "5", "<="	,""))))) 	// 5=Menor Igual	

If (cAlias)->TEQ_CONDIC == "1"

	// Data Hoje (invertido o simbolo para a consistencia SQL) 
	Do Case 
	Case (cAlias)->TEQ_OPEMAT == "1" ; cValCond := DtoS(Date() - (cAlias)->TEQ_PARAME)	// 1=Adi��o
	Case (cAlias)->TEQ_OPEMAT == "2" ;	cValCond := DtoS(Date() + (cAlias)->TEQ_PARAME)	// 2=Subtra��o
	Case (cAlias)->TEQ_OPEMAT == "3" ;	cValCond := DtoS(Date() / (cAlias)->TEQ_PARAME)	// 3=Multiplica��o
	Case (cAlias)->TEQ_OPEMAT == "4" ;	cValCond := DtoS(Date() * (cAlias)->TEQ_PARAME)	// 4=Divis�o
	EndCase
	
Else

	// Valor Parametro (invertido o simbolo para a consistencia SQL) 
	Do Case 
	Case (cAlias)->TEQ_OPEMAT == "1" ; cValCond := AllTrim(Str((cAlias)->TEQ_VLRRES - (cAlias)->TEQ_PARAME))	// 1=Adi��o
	Case (cAlias)->TEQ_OPEMAT == "2" ;	cValCond := AllTrim(Str((cAlias)->TEQ_VLRRES + (cAlias)->TEQ_PARAME))	// 2=Subtra��o
	Case (cAlias)->TEQ_OPEMAT == "3" ;	cValCond := AllTrim(Str((cAlias)->TEQ_VLRRES / (cAlias)->TEQ_PARAME))	// 3=Multiplica��o
	Case (cAlias)->TEQ_OPEMAT == "4" ;	cValCond := AllTrim(Str((cAlias)->TEQ_VLRRES * (cAlias)->TEQ_PARAME))	// 4=Divis�o
	EndCase
	
EndIf

// Pegando o X2_UNICO para consistencia do LOG
cUnico	:= Posicione("SX2",1,cTabela,"X2_UNICO")

//Verifica��o para a concatena��o dos bancos
If Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX"
	cUnico := Replace(cUnico,"+","||")
EndIf

// Montando informa��es para a Query
cWhere := "%" + (cTabela)->(cCampo) + cOpeLog + cValCond  

//Adicionando a query a verifica��o da existencia do LOG, para evitar disparo
cWhere += " AND (SELECT COUNT(*) FROM "
cWhere += RetSqlName("TFK") + " TFK "
cWhere += "WHERE TFK.TFK_CODEVE = '" + (cAlias)->TEQ_CODEVE + "' AND " 
cWhere += "RTRIM(LTRIM(TFK.TFK_VALOR)) = " + (cTabela)->(cCampo) + " AND "
cWhere += "RTRIM(LTRIM(TFK.TFK_UNICO)) = " + AllTrim(cUnico) + ") = 0%"

// Ajustes e campos para a Query
cUnico := "%" + cUnico 					+ "%"
cCmp1 	:= "%" + (cTabela)->(cCampo) 	+ "%"
cCmp2 	:= "%" + (cTabela)->(cCampRet) 	+ "%"
cTab  	:= "%" + RetSqlName(cTabela) 	+ "%"

// Carrega a tabela com a regra selecionada
BeginSql Alias cAliasUI

SELECT	%Exp:cCmp1% CP1, %Exp:cCmp2% CP2, %Exp:cUnico% UNICO 
FROM 	%Exp:cTab%
WHERE 	%Exp:cWhere% AND %NotDel%

EndSql

(cAliasUI)->(dbGoTop())

While (cAliasUI)->(!Eof())
	// Carrega a array de retorno com os campos configurados na regra	
	aAdd(aRetorno, {	(cAliasUI)->CP1,;		//Campo condi��o 
					   	(cAliasUI)->CP2,; 	//Campo retorno
					   	(cAliasUI)->UNICO })	//Campo X2_UNICO				 
	(cAliasUI)->(dbSkip())	
EndDo

(cAliasUI)->(dbCloseArea())

RestArea(aArea)

Return(aRetorno)