#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSCRD950C.CH"


WSSTRUCT DavLisX 
	WSDATA Codigo		AS String
	WSDATA Pontos  		AS String
	WSDATA Tipo 		AS String
	WSDATA Produto 		AS String
	WSDATA NumVale 		AS String
	WSDATA VlrPro 		AS Float
	WSDATA Descont 		AS Float
	WSDATA VlrVlCom		AS Float
ENDWSSTRUCT



WSSTRUCT CrdEstrCri 
	WSDATA cCodCam  		AS String
	WSDATA aCriterio		AS Array of EstaCri OPTIONAL
	WSDATA cDtIniCam		AS Date
	WSDATA cDtFinCam        AS Date
	WSDATA lRet				AS Boolean
ENDWSSTRUCT

WSSTRUCT LstFin 
	WSDATA cTipMen 		AS String
	WSDATA lUniComp 	AS Boolean
	WSDATA lTemComp 	AS Boolean
	WSDATA lRet 		AS Boolean
ENDWSSTRUCT

WSSTRUCT EstaCri 
	WSDATA Pontos  		AS Integer
	WSDATA Valor		AS String  
	WSDATA Produto		AS String 
	WSDATA PERDES		AS String 
	WSDATA Tipo			AS String 
	WSDATA Sequem       AS String 
	WSDATA Preco       	AS String 	
	WSDATA CodCam		AS String
ENDWSSTRUCT





WSSERVICE FRTCRD DESCRIPTION STR0001 // "Serviço de consultas do SIGALOJA/SIGAFRT referentes ao SIGACRD (Fidelização)"
           						   
	WSDATA CrdPonto		AS Integer 				
	WSDATA CrdLsAtFin	AS Array of LstFin	    
	WSDATA DavListReX	AS Array of DavLisx 	
	WSDATA CrdLstCrit	AS Array of CrdEstrCri 	
	WSDATA CrdCartDep   AS Boolean 				
	WSDATA lAcponto    	AS Boolean 			
	WSDATA cCliente 	AS String 	
	WSDATA cCodCam	 	AS String 	
	WSDATA cLojaCli 	AS String   
 	WSDATA nTotPontos	AS Integer  
 	WSDATA nVlrTotal	AS Float	
 	WSDATA cCartao		AS String	 
	WSDATA dDtFinCam	As Date		 
	WSDATA dDtIniCam	As Date		 
	WSDATA lRet			As Boolean	 
	
	WSMETHOD CrdVerCart DESCRIPTION STR0002 //"CRD - Verifica se é cartao de dependente"     	
	WSMETHOD CrdCriteri DESCRIPTION STR0003 //"CRD - Carrega  criteriosde de Campanha"			
	WSMETHOD CrdPontCli DESCRIPTION STR0004 //"CRD - Pontos de Cliente"							
	WSMETHOD CrdAtFin   DESCRIPTION STR0005 //"CRD - Verifica Financeiro I"                      
ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³CrdVerCart³ Autor ³ Venda Clientes        ³ Data ³24/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista os orcamentos (DAVs) emitidas dentro de um periodo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 -                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD CrdVerCart WSRECEIVE cCartao, cCliente, cLojaCli WSSEND CrdCartDep WSSERVICE FRTCRD

Local lRet := .T.	

    lRet := Crd240Cartao(cCartao, cCliente, cLojaCli)	
  
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³LstDavEmiX³ Autor ³ Venda Clientes        ³ Data ³24/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista os orcamentos (DAVs) emitidas dentro de um periodo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 -                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD CrdCriteri WSRECEIVE cCliente WSSEND CrdLstCrit WSSERVICE FRTCRD  
											   
Local cCodCam	:= ""
Local aCriterio := {}
LOcal cDtIniCam := ""
LOcal cDtFinCam := ""
Local lRet		:= .T.
Local nX 		:= 0
	
	lRet := Crd240Criterio( @cCodCam, @aCriterio, @cDtIniCam, @cDtFinCam )
	
	AAdd(::CrdLstCrit,WSClassNew("CrdEstrCri"))

  	::CrdLstCrit[1]:cCodCam  		:= cCodCam
	::CrdLstCrit[1]:aCriterio  := Array( Len(aCriterio), 5 )
				

	For nX := 1 To Len(aCriterio)   
		::CrdLstCrit[1]:aCriterio[nX] 			  := WSClassNew("EstaCri")	 		    				 
		::CrdLstCrit[1]:aCriterio[nX]:Pontos    	:= aCriterio[nX][1]
		::CrdLstCrit[1]:aCriterio[nX]:Valor      	:= aCriterio[nX][2]
		::CrdLstCrit[1]:aCriterio[nX]:Produto  	:= aCriterio[nX][3]
		::CrdLstCrit[1]:aCriterio[nX]:PERDES 		:= aCriterio[nX][4]
		::CrdLstCrit[1]:aCriterio[nX]:Tipo 		:= aCriterio[nX][5]
		::CrdLstCrit[1]:aCriterio[nX]:Sequem 		:= aCriterio[nX][6]
		::CrdLstCrit[1]:aCriterio[nX]:Preco 		:= aCriterio[nX][7]		
		::CrdLstCrit[1]:aCriterio[nX]:CodCam 		:= aCriterio[nX][8]
	
	Next nX
	
	::CrdLstCrit[1]:cDtIniCam 		:= cDtIniCam
	::CrdLstCrit[1]:cDtFinCam 		:= cDtFinCam
	::CrdLstCrit[1]:lRet 			:= lRet


Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³CrdPontCli³ Autor ³ Venda Clientes        ³ Data ³24/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista os orcamentos (DAVs) emitidas dentro de um periodo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 -                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD CrdPontCli WSRECEIVE cCliente, cLojaCli, cCodCam, lAcponto WSSEND CrdPonto WSSERVICE FRTCRD

Local nPontos

nPontos := CrdPontCli(cCliente, cLojaCli, cCodCam, lAcponto)
::CrdPonto := nPontos

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³CrdPontCli³ Autor ³ Venda Clientes        ³ Data ³24/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista os orcamentos (DAVs) emitidas dentro de um periodo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 -                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD CrdAtFin WSRECEIVE dDtIniCam, dDtFinCam, cCliente, cLojaCli, lRet WSSEND CrdLsAtFin WSSERVICE FRTCRD

Local cTipMen	:= ""
Local lUniComp		:= .T.
Local lTemComp  	:= .F.
Local lRetFun		:= .T.
Local cDtIniCam
Local cDtFinCam

cDtIniCam := DTOC(dDtIniCam)
cDtFinCam := DTOC(dDtFinCam)

AAdd(::CrdLsAtFin,WSClassNew("LstFin"))

lRetFun := Crd240aAtFin(@cTipMen, @lUniComp, @lTemComp, cDtIniCam, cDtFinCam, cCliente, cLojaCli, lRet)
::CrdLsAtFin[1]:cTipMen 		:= cTipMen
::CrdLsAtFin[1]:lUniComp 		:= lUniComp
::CrdLsAtFin[1]:lTemComp 		:= lTemComp
::CrdLsAtFin[1]:lRet 			:= lRetFun

Return(.T.)

