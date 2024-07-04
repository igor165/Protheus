#include 'protheus.ch'
#INCLUDE "TBICONN.CH"
#include "AGRA790.ch"

/*
Programa responsável pelo Update dos registros dos cadastros de Safra, Produtores, Talhoes e Variedades, 
do banco de dados do Pims para o Protheus. 

Tabelas 						Pims(origem)		Protheus(Destino)

Produtores   					- PROPRIETARIO		-DX8 - Compartilhado
Talhoes    					- UPNIVEL3				-NN3 - Compartilhado
Variedades    				- VARIEDADE			-NNV - Compartilhado
Variedades nos Talhoes		- ????					-NN4 - Compartilhado

*/  
Function AGRA790()		
	Local aArea	    	:= GetArea()
	Local aTabsDest   	:= {"NN3","NN4"}
	Private cTPConect 	:= "TCPIP" // Tipo de conexao que sera usada 
	
	if isblind()  
    	SchedDef()					//Chama Pergunte pelo Schedule
    else
    	if !Pergunte('AGRA790',.T.)  //Chama e exibe perguntas
    		return
    	endif  
    endif
        
	Private cBDori			:= ALLTRIM(MV_PAR01) 	
	Private cIPSvrOri  		:= ALLTRIM(MV_PAR02)	
	Private nPortTopOri		:= MV_PAR10  
	Private _ConnPims 		:= 0

	Private cBDDest			:= ALLTRIM(MV_PAR03) 	
	Private cIPSrvDest		:= ALLTRIM(MV_PAR04) 	
	Private nPortTopDest	:= MV_PAR11   
	Private _ConnProtheus	:= 0 
	
	Private aCamposDest	    := {}	
	//Seta o tipo de conexão
	TCCONTYPE(cTPConect)
	
	_ConnPims 		:= TCLink(cBDori,cIPSvrOri,nPortTopOri)  		// conexao com  PIMS Origem
	_ConnProtheus := TCLink(cBDDest,cIPSrvDest,nPortTopDest) 	// conexao com Protheus 


	cPortOn := cValToChar(nPortTopOri)
	cPortOf := cValToChar(nPortTopDest)

	If _ConnPims < 0
		ALERT("Erro ao tentar conexão com o banco de dados " + cBDori + " através do TopConnect/DBAcces localizado no servidor de aplicações: " + cIPSvrOri + " Porta TCP/IP" + cPortOn)
	ElseIf _ConnProtheus < 0
		ALERT("Erro ao tentar conexão com o banco de dados " + cBDDest + " através do TopConnect/DBAcces localizado no servidor de aplicações "+ cIPSrvDest + " Porta TCP/IP" + cPortOf)
	Else
		ALERT("conexões TopConnect/DBAcces OK!")		

		// Buscas as informações e as atualiza no banco Destino
		lOkOff = AGRIntOriDest(aTabsDest, _ConnPims, _ConnProtheus)
			
	EndIf

	TCUnlink ( _ConnPims )
	TCUnlink ( _ConnProtheus )

	//RpcClearEnv()
	RestArea( aArea )
Return( Nil )

Static Function SchedDef()

Return { "P", "AGRA790", "", {}, "" }

/**
**
** Função de Integração de Banco Origem (Protheus) com Destino (Pims)
** -> As informações das tabelas DX5, DX6, DXC, DXE e DXL são buscas no banco Origem e atualizadas no
**    Destino 
****/
Static Function AGRIntOriDest(aTabsDest, _ConnPims, _ConnProtheus)
	Local nX,nY		  	:= 0
	Local cAliasPIMS	:= ""	
	local lRet      	:=.T.
	
	For nX := 1 to Len( aTabsDest )

		//conectando com o PIMS Origem
		TCSETCONN(_ConnPims)	
				
		if 	aTabsDest[nX] == "NN3"	
				cAliasPIMS:= NN3Load()
		elseif aTabsDest[nX] == "NN4"			
				cAliasPIMS:= NN4Load()	
		endif
		
	//TODO MAICOL exemplo de contagem de registro do select	 
	nY := 0
	(cAliasPIMS)->(dbEval({|| nY++}))
			
	DbGoTop()
	
		While (cAliasPIMS)->(!Eof())
			Begin Transaction
				TCSETCONN(_ConnProtheus)
				//Importa os registro para a base Destino
				lRet:= AGRUpdate(cAliasPIMS, aTabsDest[nX]) //Grava os registros na base Destino.
			End Transaction
			If !lRet
				//ConOut("Erro na sincronizacao da " + aTabsDest[nX])
				//Mostraerro("c:\temp\","UBAlog.log")
			EndIf

			(cAliasPIMS)->(DbSkip())
                
		EndDo

		(cAliasPIMS)->(DbCloseArea())
	Next nX

Return (lRet)
/**----------------------------------------------------------------------------**/


/**
**
** Função para gravação dos registro na base do Protheus
**
**/
Static Function AGRUpdate(cAliasPIMS, cTab)
	Local aArea 	     := GetArea()
	Local aCampos  		 := {}
	Local nX			 := 0
	Local cChave01		 := ""
	Local cChave02		 := ""	
	Local cChave03 		 := ""
	Local cChave04		 := ""		
	Local cSeek			 := ""
	Local lRet			 := .T.
	Local cAliasFazenda  := '' 
	Local cAliasVariedade:= ''
	Local nIndex		 := 1
	Local cMsg 			 := STR0001 + cTab+" "
	
	if 	(cTab == "NN3") // Talhão
		cAliasFazenda	:= BuscaFazenda(cAliasPIMS)
		if !Empty(cAliasFazenda)//verificar se existe  fazenda com vinculo com o pims
			aCampos		:= {"SAFRA", "FAZENDA", "CODTALHAO", "NOMTALHAO", "AREA", "PRODUTO","NN3_FECHAD","NN3_YPIMS", "UM", "FILIAL"}		
			aCamposDest 	:= {"NN3_SAFRA","NN3_FAZ","NN3_TALHAO", "NN3_DESCRI", "NN3_HECTAR", "NN3_CODPRO","NN3_FECHAD","NN3_YPIMS","NN3_UM1PRO", "NN3_FILIAL"}
			//INDEX = NN3_FILIAL+NN3_SAFRA+NN3_FAZ+NN3_TALHAO			
			cChave01 := ALLTRIM((cAliasPIMS) -> SAFRA)
			cChave02 := ALLTRIM((cAliasFazenda) -> FAZENDA)
			cChave03 := ALLTRIM((cAliasPIMS) -> CODTALHAO)
			cSeek := xFilial(cTab)
			nIndex := 1
			cSeek += cChave01 + Space(len(NN3->NN3_SAFRA) - len(cChave01)) + cChave02 + Space(len(NN3->NN3_FAZ) - len(cChave02))+ cChave03 + Space(len(NN3->NN3_TALHAO) - len(cChave03))
		else
			lRet = .F.
		endif
	endif

	if 	(cTab == "NN4")
		cAliasFazenda		:= BuscaFazenda(cAliasPIMS)
		cAliasVariedade 	:= BuscaVariedade(cAliasPIMS)
		if !Empty(cAliasFazenda) .and. !Empty(cAliasVariedade) //verificar se existe  fazenda com vinculo com o pims	
			aCampos		:= {"SAFRA", "FAZENDA", "CODTALHAO", "CODVARIEDADE", "AREA", "ITEM", "DESVARIEDADE", "FILIAL"}		
			aCamposDest 	:= {"NN4_SAFRA","NN4_FAZ","NN4_TALHAO", "NN4_CODVAR", "NN4_HECTAR","NN4_ITEM", "NN4_DESVAR", "NN4_FILIAL" }
			//INDEX = NN4_FILIAL+NN4_SAFRA+NN4_FAZ+NN4_TALHAO+NN4_CODVAR	
			cChave01 := ALLTRIM((cAliasPIMS) -> SAFRA)
			cChave02 := ALLTRIM((cAliasFazenda) -> FAZENDA)
			cChave03 := ALLTRIM((cAliasPIMS) -> CODTALHAO)
			cChave04 := ALLTRIM((cAliasVariedade) -> CODVARIEDADE)
			cSeek := xFilial(cTab)
			nIndex := 2
			cSeek += cChave01 + Space(len(NN4->NN4_SAFRA) 	- len(cChave01))
			cSeek += cChave02 + Space(len(NN4->NN4_FAZ) 		- len(cChave02))
			cSeek += cChave03 + Space(len(NN4->NN4_TALHAO) 	- len(cChave03))
			cSeek += cChave04 + Space(len(NN4->NN4_CODVAR) 	- len(cChave04))
		else
			lRet = .F.
		endif		
	endif

	if (lRet)
		dbSelectArea(cTab)
		dbSetOrder( nIndex )
		If DbSeek(cSeek)
			RecLock(cTab,.F.)
		Else
			RecLock(cTab,.T.)
		EndIf
	
		For nX:= 1 To Len(aCamposDest)
			If Valtype(&(aCamposDest[nX])) == "D" .And. ValType((cAliasPIMS)->&(aCampos[nX])) == "C"
				Replace &(aCamposDest[nX]) With sTod((cAliasPIMS)->&(aCampos[nX]))
			elseif aCamposDest[nX] = "NN3_FAZ" .or. aCamposDest[nX] = "NN4_FAZ" 
				Replace &(aCamposDest[nX]) With (cAliasFazenda)->&(aCampos[nX])
			elseif aCamposDest[nX] = "NN4_DESVAR" .or. aCamposDest[nX] = "NN4_CODVAR"
				Replace &(aCamposDest[nX]) With (cAliasVariedade)->&(aCampos[nX])
			elseif aCamposDest[nX] = "NN3_FILIAL" 
				Replace &(aCamposDest[nX]) With FWxFilial("NN3") 	
			elseif aCamposDest[nX] = "NN4_FILIAL" 
				Replace &(aCamposDest[nX]) With FWxFilial("NN4") 	
			elseif aCamposDest[nX] = "NN3_UM1PRO"
				Replace &(aCamposDest[nX]) With Posicione("SB1", 1,FWxFilial("SB1") + MV_PAR07, "B1_UM")
			else
				Replace &(aCamposDest[nX]) With (cAliasPIMS)->&(aCampos[nX])
			EndIf  
			
		Next nX
		FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})    
		MsUnlock()
	endif
	
	Iif (!Empty(cAliasFazenda), 	(cAliasFazenda)->(DbCloseArea()) , nil)
	if  (!Empty(cAliasVariedade),  (cAliasVariedade)->(DbCloseArea()),nil)
	
	RestArea(aArea)
		
Return(lRet)
/**------------------------------------------------------------**/



/*
** Função que busca a fazenda no protheus atraves do ID do PIMS
**	
*/
static Function BuscaVariedade(cAliasPIMS)
	Local cQry			:= ""
	Local cAliasQry		:= ""
	Local cMsg			:= STR0002 + ALLTRIM((cAliasPIMS) -> CODVARIEDADE)+STR0003
	
	//BUSCA VARIEDADE PELO ID DO PIMNS
	cAliasQry:= GetNextAlias( )
	cQry += "SELECT NNV_CODIGO AS CODVARIEDADE , NNV_DESCRI AS DESVARIEDADE  FROM "
	cQry += RetSqlName("NNV") +" "
	cQry += " WHERE NNV_FILIAL = '"+xFilial("NNV")+"' AND RTRIM(LTRIM(NNV_YPIMS)) ='"+ALLTRIM((cAliasPIMS) -> CODVARIEDADE)+"' "
	cQry += " AND D_E_L_E_T_ = ' '"
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()
	
	If (cAliasQry)->(Eof())
		(cAliasQry)->(dbclosearea())
		FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})    
		cAliasQry	:= ""
	endif
	
return(cAliasQry)

/**------------------------------------------------------------**/
/** Função que busca a fazenda no protheus atraves do ID do PIMS
**	
**------------------------------------------------------------**/
static FUNCTION BuscaFazenda(cAliasPIMS)
	Local cQry		:= ""
	Local cAliasQry	:= ""
	Local cMsg		:= STR0004 + ALLTRIM((cAliasPIMS) -> ID_FAZENDA)+ STR0003

	//BUSCA FAZENDA PELO ID DO PIMNS
	cAliasQry:= GetNextAlias( )
	cQry += "SELECT NN2_CODIGO AS FAZENDA FROM "
	cQry += RetSqlName("NN2") +" "
	cQry += " WHERE NN2_FILIAL = '"+xFilial("NN2")+"' AND RTRIM(LTRIM(NN2_YPIMS)) ='"+ALLTRIM((cAliasPIMS) -> ID_FAZENDA)+"' "
	cQry += " AND NN2_ATIVA='A' AND D_E_L_E_T_ = ''
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()
	
	If (cAliasQry)->(Eof())
		(cAliasQry)->(dbclosearea())		
		FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {}) 
		cAliasQry	:= ""
	endif
		
return(cAliasQry)
/**------------------------------------------------------------**/



/****
**
** Função para o carregamento dos registros de Talhoes da base do PIMS
**	
mv_par05 = Safra 	 	-  ira gravar no protheus
mv_par06 = sequencia -  ira gravar no protheus
MV_PAR07 = Produto	-  ira gravar no protheus
MV_PAR08 = Periodo 	-  do PIMS
****/
Static Function NN3Load()
	Local cQry		  := ""
	Local cAliasQry := ""
	cAliasQry:= GetNextAlias( )
	cQry := " SELECT '" + alltrim(MV_PAR05) + alltrim(MV_PAR06) + "' AS SAFRA, "

	If TcGetDB() == 'MSSQL'
		cQry += "CAST(F.ID_UPNIVEL1 AS VARCHAR) AS ID_FAZENDA,"
		cQry += "CAST(T.ID_UPNIVEL3 AS VARCHAR) AS NN3_YPIMS, "
		cQry += "CAST(T.ID_UPNIVEL3 AS VARCHAR) AS  ID_TALHAO, "	
		cQry += "SUBSTRING(T.CD_UPNIVEL3,1,10) AS CODTALHAO, "	
		cQry += "CONCAT( 'TH ' , SUBSTRING(T.CD_UPNIVEL3,1,10)) AS NOMTALHAO, "
	Else
		cQry += "TO_CHAR(F.ID_UPNIVEL1) AS ID_FAZENDA,"
		cQry += "SUBSTR(T.CD_UPNIVEL3,1,10) AS CODTALHAO, "
		cQry += "TO_CHAR(T.ID_UPNIVEL3) AS NN3_YPIMS, "
		cQry += "CONCAT( 'TH ' , SUBSTR(T.CD_UPNIVEL3,1,10)) AS NOMTALHAO, "
	EndIf
	
	cQry += "'N' AS NN3_FECHAD,"	
	cQry += "T.QT_AREA_PROD AS AREA, '"
	cQry += ALLTRIM(MV_PAR07) + "' AS PRODUTO "		
	cQry += "FROM UPNIVEL3 T "
	cQry += "JOIN PERIODOSAFRA PS ON T.ID_PERIODOSAFRA=PS.ID_PERIODOSAFRA "
	cQry += "JOIN SAFRA S ON PS.ID_SAFRA=S.ID_SAFRA "		
	cQry += "JOIN UPNIVEL2 TF ON T.ID_UPNIVEL2=TF.ID_UPNIVEL2 "
	cQry += "JOIN UPNIVEL1 F ON TF.ID_UPNIVEL1=F.ID_UPNIVEL1 "
	cQry += "JOIN	PROPRIETARIO P ON  P.id_proprietario = F.id_proprietario  
	cQry += "WHERE PS.CD_PER_SAFRA='" + ALLTRIM(MV_PAR08) + "'"
	cQry += "AND P.CD_PROPRIET ='" + ALLTRIM(MV_PAR09) +"'"
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .T., .F. )
	DbGoTop()	
Return(cAliasQry)

/**------------------------------------------------------------**/
/****
**
** Função para o carregamento dos registros de Variedades nos Talhoes da base Origem
**
****/
Static Function NN4Load()
	Local cQry		  := ""
	Local cAliasQry := ""

	cAliasQry:= GetNextAlias( )
	
	cQry := "SELECT '" + alltrim(mv_par05) + alltrim(mv_par06) + "' AS SAFRA, "

	If TcGetDB() == 'MSSQL'
		cQry += "CAST(F.ID_UPNIVEL1 AS VARCHAR) AS ID_FAZENDA, "
		cQry += "SUBSTRING(T.CD_UPNIVEL3,1,10) AS CODTALHAO, "
		cQry += "CAST(V.ID_VARIEDADE AS VARCHAR) AS CODVARIEDADE, "
	Else
		cQry += "TO_CHAR(F.ID_UPNIVEL1) AS ID_FAZENDA, "
		cQry += "SUBSTR(T.CD_UPNIVEL3,1,10) AS CODTALHAO, "
		cQry += "TO_CHAR(V.ID_VARIEDADE) AS CODVARIEDADE, "
	EndIf
	
	cQry += "T.QT_AREA_PROD AS AREA, '1' AS ITEM "
	cQry += "FROM UPN3_VAR VT "
	cQry += "JOIN UPNIVEL3 T ON VT.ID_UPNIVEL3 = T.ID_UPNIVEL3 "
	cQry += "JOIN PERIODOSAFRA PS ON T.ID_PERIODOSAFRA = PS.ID_PERIODOSAFRA "
	cQry += "JOIN SAFRA S ON S.ID_SAFRA=PS.ID_SAFRA "
	cQry += "JOIN VARIEDADE V ON VT.ID_VARIEDADE = V.ID_VARIEDADE "
	cQry += "JOIN UPNIVEL2 W ON W.ID_UPNIVEL2 = T.ID_UPNIVEL2 "
	cQry += "JOIN UPNIVEL1 F ON W.ID_UPNIVEL1 = F.ID_UPNIVEL1 "
	cQry += "JOIN OCUPACAO O ON V.ID_OCUPACAO = O.ID_OCUPACAO "
	cQry += "JOIN	PROPRIETARIO P ON  F.id_proprietario = P.id_proprietario "
	cQry += "WHERE PS.CD_PER_SAFRA='" + ALLTRIM(MV_PAR08) + "'"
	cQry += "AND P.CD_PROPRIET ='" + ALLTRIM(MV_PAR09) +"'"
	// ALGODÃO
	cQry := ChangeQuery( cQry )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()

Return(cAliasQry)
/**------------------------------------------------------------**/

