/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORGXFUN    ºAutor  ³Equipe Advanced RH        º Data ³  06/26/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Biblioteca de Funcoes para uso no SIGAORG                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgr.      ³Data      ³ BOPS/FNC  ³Motivo da Alteracao                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCecilia C.  ³31/03/2014³151223     ³Ajuste na funcao OrgRelationFile para     º±±
±±º            ³          ³           ³verificar compatibilidade entre modos     º±±
±±º            ³          ³           ³apenas das tabelas RCL/RBU/RBT/RBX        º±±
±±ºCecilia C.  ³07/08/2014³TQEQKP     ³Limpeza do fonte.                         º±±
±±ºRaquel Hager³06/06/2016³TVDLLJ     ³Removido chamada da função OpenSXS da     º±±
±±º            ³          ³           ³função OrgxOpenFile.		                  º±±
±±ºMarcelo F.  ³21/05/2017³DRHPONTP   ³Ajuste de origem da transferência,        º±±
±±º            ³          ³-604       ³quando utilizado controle de postos       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/     
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ORGXFUN.CH"

Static nTamDpt
Static cFuncCall := FunName()
Static cOrgCfg   := SuperGetMv("MV_ORGCFG",NIL,0)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OrgRelationFile ³ Autor ³ Rogerio R. Cruz  ³ Data ³ 26/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o Relacionamentos dos Arquivos do Modulo Org          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGLOAD() - SIGAORG - Arquitetura Organizacional.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lShowHelp: Exibe ou nao a mensagem de Help				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetModo													    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡„o³                                                      	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generica                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OrgRelationFile(lFinal)
	Local nCount
	Local cMessage
	Local lRetModo	:= .T.
	Local aFiles	:= {	{"RCL", "RBU"},;//Cadastro de Postos+Movimentacao de Postos
							{"RCL", "RBT"},;//Cadastro de Postos+Mov de Estrutura de Departam
							{"RCL", "RBX"},;//Cadastro de Postos+Operacoes em Mov Departamento
							{"RCL", "RCX"},;//Cadastro de Postos+Ocupantes do posto
							{"RDK", "RD4"},;//Visoes+Itens de Visoes
							{"RD4", "RCD"} }//Itens de Visoes+Historico de Itens de Visoes
	
	Static lOrgChkRel
	Static cLastEmpChk
	
	Default lFinal	:= .F.

	CursorWait()
	
	Begin Sequence
		DEFAULT lOrgChkRel 	:= .T.
		DEFAULT cLastEmpChk	:= cEmpAnt
		
		IF ( cLastEmpChk <> cEmpAnt )
			lOrgChkRel := .T.
		EndIF
		
		IF !( lOrgChkRel )
			Break
		EndIF
		
		IF !( lRetModo := Rd0ChkModo( .F. ) )
			cMessage:= OemToAnsi(STR0003) + " RD0 " + OemToAnsi(STR0004)
			Break
		EndIF
		
		IF !( lRetModo := RdZChkModo( .F. ) )
			cMessage:= OemToAnsi(STR0003) + " RDZ " + OemToAnsi(STR0004)
			Break
		EndIF
		
		For nCount:= 1 To Len(aFiles)
			IF !( lRetModo := xRetModo(aFiles[nCount, 1] , aFiles[nCount, 2] , .F. ) )
				cMessage:= OemToAnsi(STR0005) + " " + aFiles[nCount, 1] + " " + OemToAnsi(STR0006) + " " + aFiles[nCount, 2] + " " + OemToAnsi(STR0007)
				Break
			EndIF
		Next
	End Sequence
	
	If !lRetModo .AND. lFinal
		Final(cMessage)
	EndIf	

	
	CursorArrow()
	
	//Se estiver Tudo Ok nao verifica Novamente
	lOrgChkRel := !lRetModo
Return lRetModo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OrgxOpenFile    ³ Autor ³ Marcos Alves     ³ Data ³ 17/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abertura das tabelas de outra empresas e dicionários, para   ³±±
±±³          ³ funcionamento das query de embedded                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OrgxOpenFile(aFiles,cEmp)									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aFiles - Tebelas a serem abertas na empresa					³±±
±±³          ³ cEmp   - Codigo da empresa a ser abertos as tabelas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nada     										            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡„o³                                                      	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAORG                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OrgxOpenFile(aFiles,cEmp)
	Local nLoops	:=Len(aFiles)
	Local nX
	Local cModo		:=""
	Local lOpen		:=.T.
	Local aSxs		:=RetSxs()
	Local cAlias	:=""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fechar as tabelas antes de abrir, pois vai abrir no mesmo alias	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:=1 to Len(aSxs)
		cAlias 	:= If("SX"$aSxs[nX,1],aSxs[nX,1],"SIX")
		IF Select(cAlias) > 0
			dbSelectArea(cAlias)
			dbCloseArea()
		Endif	
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicionar na empresa a ser aberto os dicionario				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SM0->(dbSeek(cEmpAnt))
	For nX:=1 to Len(aSxs)
		cAlias 	:= If("SX"$aSxs[nX,1],aSxs[nX,1],"SIX")
		OpenSxs(,,,,,,cAlias)
	Next nX
	
	For nX:=1 to nLoops
		lOpen:=EmpOpenFile(	aFiles[nX,1],;			//cExp1 - Alias com o Qual o Arquivo Sera Aberto
		   					aFiles[nX,1],;		//cExp2 - Alias do Arquivo Para Pesquisa e Comparacao           
							1		,;	  		//nExp3 - Ordem do Arquivo a Ser Aberto                         
							.T.		,;			//lExp4 - .T. Abre e .F. Fecha                                  
							cEmp	,;			//cExp5 - Empresa                                               
							@cModo)				//cExp6 - Modo de Acesso (Passar por Referencia)                
		
	
		aFiles[nX,2]:=If(lOpen,cModo,"X")
	Next nX
Return
               


//-----------------------------------------------------------------------------
//<summary>
//		Libera os postos ocupados pelo funcionario.
//</summary>
//<param name="cFilFun">Filial do Funcionario</param>
//<param name="cMatFun">Matricula do Funcionario</param>
//<param name="dDataBaixa">Data de demissao do Funcionario</param>
//<remarks></remarks>
//<history>
// 	<change date="08/07/2008" user="rogerio.ribeiro">Criacao da funcao.</change>
//</history>
//-----------------------------------------------------------------------------
Function OrgXRescisao(cFilFun, cMatFun, dDataBaixa)
   	Local oPostos	:= ArrayList():New()
	Local aArea 
	Local aAreaSRA
	Local aAreaRCX
	Local aAreaRCL
	Local aAreaRBU
   	Local cPosto
   	Local nCount
	Local nGetSX8Len
	
	If GetMv("MV_ORGCFG", NIL, "0") != "1"
		Return {}
	Endif
 	   	
	SX2->(dbSetOrder(1))	
	If !SX2->(dbSeek("RCX"))
		Return {}
	Endif
	
	aArea 	:= GetArea() 
	aAreaSRA	:= SRA->( GetArea() )
	aAreaRCX	:= RCX->( GetArea() )
	aAreaRCL	:= RCL->( GetArea() )
	aAreaRBU	:= RBU->( GetArea() )
   	   		
   	dbSelectArea("RCX") 	
	dbSetOrder(4)	//RCX_FILIAL+RCX_FILFUN+RCX_MATFUN+RCX_POSTO

   //Necessário realizar a busca na tabela de ocupações utilizando a mesma filial do funcionário
   //pois no caso de transferências de filial+ posto, essa funcionalidade deverá realizar as
   //baixas na filial de origem e não na filial de destino *xFilial("RCX")*
   //visto que no processo de transferência quando se opta pela troca de filial, o posto deve
   //acompanhar a mesma filial do funcionário, na atualização do campo RA_POSTO.
	If !RCX->(dbSeek(xFilial("RCX",cFilFun) + cFilFun + cMatFun))
		Return {}
 	EndIf	
 	
	RBU->(dbSetOrder(1)) //RBU_FILIAL+RBU_POSTO+RBU_CODMOV
	
	nGetSX8Len:= GetSX8Len()
	
	While !RCX->(Eof())                .AND.;
           RCX->RCX_FILFUN == cFilFun .AND.;
           RCX->RCX_MATFUN == cMatFun 
		
		cPosto := RCX->RCX_POSTO 
		oPostos:Add( RCX->(RECNO()) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizar o posto											 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RCL->(dbSetOrder(2))
		
	 	If RCL->(DBSeek(xFilial("RCL",cFilFun) + cPosto))
	 		If RCX->RCX_SUBST == "2"
				RCL->(RecLock("RCL",.F.))
				RCL->RCL_OPOSTO	:= 	If(RCL->RCL_OPOSTO>=1,RCL->RCL_OPOSTO-1,0)
				RCL->RCL_STATUS	:=	If(RCL->RCL_OPOSTO==0,"1",RCL->RCL_STATUS)	// 1=Livre;2=Ocupado;3=Congelado;4=Cancelado
				RCL->(MsUnLock())
			EndIf
		EndIf
		
		If RBU->(DBSeek(xFilial("RBU",cFilFun) + cPosto))
			While !RBU->(EOF())               .AND.;
					RBU->RBU_FILIAL == xFilial("RBU",cFilFun) .AND.;
					RBU->RBU_POSTO  == cPosto		

				If RBU->RBU_FILFUN == cFilFun .AND.;
				   RBU->RBU_MATFUN == cMatFun .AND.;
				   RBU->RBU_DTFIM == CTOD("  /  /  ")
				   
					RBU->(RecLock("RBU", .F.))
					RBU->RBU_DTFIM 	:=	dDataBaixa
					RBU->(MsUnLock())
				EndIf

				RBU->(dbSkip())
			EndDo
			        
		EndIf
		
		RCX->(dbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processo de exclusao dos registros do ocupante para nao perder³
	//³ o ponteiro												      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For nCount:= 1 to oPostos:GetCount()
    	RCX->( DBGoto( oPostos:GetItem(nCount) ) )
    	
    	oPostos:SetItem(nCount, RCX->RCX_POSTO)
    	
		RCX->( RecLock("RCX",.F., .T.))
		RCX->( DBDelete())	
		RCX->( MsUnLock())
	Next nCount
	      
	SRA->(DBSetOrder(1))
	
	If SRA->(DBSeek(cFilFun + cMatFun))
		SRA->(RecLock("SRA",.F.))
		SRA->RA_POSTO:= ""
		SRA->(MsUnLock())
	EndIf
	
	While ( GetSX8Len() > nGetSX8Len )
		ConfirmSX8()
	End While	

	RestArea(aAreaRBU)
	RestArea(aAreaRCL)
	RestArea(aAreaRCX)
	RestArea(aAreaSRA)
	RestArea(aArea)
Return oPostos:ToArray()


//-----------------------------------------------------------------------------
//<summary>
//		
//</summary>
//<param name="cFilFun">Filial do Funcionario</param>
//<param name="cMatFun">Matricula do Funcionario</param>
//<remarks></remarks>
//<history>
// 	<change date="08/07/2008" user="rogerio.ribeiro">Criacao da funcao.</change>
//</history>
//-----------------------------------------------------------------------------
Function OrgXDelRescisao(cFilFun, cMatFun)
   	Local cQuery	:= GetNextAlias()   	
	Local aArea
	Local aAreaSRA
	Local aAreaRCX
	Local aAreaRCL
	Local aAreaRBU
   	Local lPrincipal
	Local nGetSX8Len
   	
   	
   	If GetMv("MV_ORGCFG", NIL, "0") != "1"
		Return
	Endif
 	   	
	SX2->(dbSetOrder(1))	
	If !SX2->(dbSeek("RCX"))
		Return
	Endif
   	
	aArea	:= GetArea() 
	aAreaSRA:= SRA->( GetArea() )
	aAreaRCX:= RCX->( GetArea() )
	aAreaRCL:= RCL->( GetArea() )
	aAreaRBU:= RBU->( GetArea() )

	nGetSX8Len:= GetSX8Len()
   	
	BEGINSQL ALIAS cQuery
		COLUMN RBU_DTINI AS DATE
		
		SELECT 
			RBU_POSTO,
			RBU_DTINI,
			R_E_C_N_O_
		FROM 
			%table:RBU% RBU
		WHERE
			RBU_FILFUN = %exp:cFilFun% AND 
			RBU_MATFUN = %exp:cMatFun% AND 
			RBU_OPERAC = '3' AND 
			(RBU_SUBST = '2' OR RBU_SUBST = ' ') AND 
			%NotDel%  
		ORDER BY 
			RBU_DTFIM DESC
	ENDSQL
	
	If !(cQuery)->(Eof())
		RCL->(dbSetOrder(2))
		
	 	If RCL->(DBSeek(xFilial("RCL") + (cQuery)->RBU_POSTO ) )	            
		 	lPrincipal:= RCL->RCL_OPOSTO < RCL->RCL_NPOSTO
		 	
			RCL->(RecLock("RCL", .F.))
			RCL->RCL_OPOSTO	:= 	If(lPrincipal, RCL->RCL_OPOSTO + 1, RCL->RCL_NPOSTO)				
			RCL->RCL_STATUS	:=	If(RCL->RCL_OPOSTO ==  RCL->RCL_NPOSTO, "2", RCL->RCL_STATUS)	// 1=Livre;2=Ocupado;3=Congelado;4=Cancelado								
			RCL->(MsUnLock())
	 	
			RCX->( RecLock("RCX", .T.))
	       	RCX->RCX_FILIAL	:= xFilial("RCX")
	       	RCX->RCX_POSTO	:= (cQuery)->RBU_POSTO
			RCX->RCX_TIPOCU	:= "1"
			RCX->RCX_DTINI	:= (cQuery)->RBU_DTINI
			RCX->RCX_DTFIM	:= CTOD("//")
			RCX->RCX_FILFUN	:= cFilFun
			RCX->RCX_MATFUN	:= cMatFun
			RCX->RCX_SUBST 	:= If(lPrincipal, "2", "1")
			RCX->( MsUnLock())	

		 	RBU->( DBGoto( (cQuery)->R_E_C_N_O_ ))
			RBU->( RecLock("RBU", .F. ))
			RBU->RBU_DTFIM:= CTOD("//")
			RBU->( MsUnLock())				             
			     
			SRA->(DBSetOrder(1))
		
			If SRA->(DBSeek(cFilFun + cMatFun))
				SRA->(RecLock("SRA",.F.))
				SRA->RA_POSTO:= (cQuery)->RBU_POSTO
				SRA->(MsUnLock())
			EndIF
		EndIf
	EndIf

	(cQuery)->(DBCloseArea())
	
	While ( GetSX8Len() > nGetSX8Len )
		ConfirmSX8()
	End While	

	RestArea(aAreaRBU)
	RestArea(aAreaRCL)
	RestArea(aAreaRCX)
	RestArea(aAreaSRA)
	RestArea(aArea)
Return

//-----------------------------------------------------------------------------
//<summary>
//		
//</summary>
//<param name="cFilFun">Filial do Funcionario</param>
//<param name="cMatFun">Matricula do Funcionario</param>
//<param name="cPosto">Codigo do posto</param>
//<param name="dDataOcupacao">Data de inicio da ocupacao do posto</param>
//<param name="cFilPessoa">Filial do Participante</param>
//<param name="cCodPessoa">Codigo do Participante</param>
//<remarks></remarks>
//<history>
// 	<change date="08/07/2008" user="rogerio.ribeiro">Criacao da funcao.</change>
//</history>
//-----------------------------------------------------------------------------
Function OrgXOcupacao(cFilFun, cMatFun, cPosto, dDataOcupacao, cFilPessoa, cCodPessoa)
	Local aArea
	Local aAreaSRA
	Local aAreaRCX
	Local aAreaRCL
	Local aAreaRBU
	Local lExistePessoa
	Local nGetSX8Len
	Local lCadFun := IsInCallStack("GPEA010") .And. !INCLUI
	
 	If GetMv("MV_ORGCFG", NIL, "0") != "1"
		Return
	Endif
 	   	
	SX2->(dbSetOrder(1))	
	If !SX2->(dbSeek("RCX"))
		Return
	Endif
	
	dbSelectArea("RCL")
	RCL->(dbSetOrder(2))
        
 	If !RCL->(dbSeek(xFilial("RCL")+ cPosto))
 		Return .T.
 	EndIf
 	
	aArea	:= GetArea() 
	aAreaSRA:= SRA->( GetArea() )
	aAreaRCX:= RCX->( GetArea() )
	aAreaRCL:= RCL->( GetArea() )
	aAreaRBU:= RBU->( GetArea() )	
	
	nGetSX8Len:= GetSX8Len()
	
	If cFilPessoa == NIL .OR. cCodPessoa == NIL
		lExistePessoa:= ExistePessoa("SRA", cFilFun + cMatFun)
	Else
		lExistePessoa:= !Empty(cCodPessoa)
	EndIf
 	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Registro de movimentacao do posto							   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RBU->(RecLock("RBU", .T.))
	RBU->RBU_FILIAL 	:=	xFilial("RBU")
	RBU->RBU_POSTO 		:=	RCL->RCL_POSTO
	RBU->RBU_PROCES		:=	RCL->RCL_PROCES
	RBU->RBU_DEPTO		:=	RCL->RCL_DEPTO                             
	RBU->RBU_CODMOV		:=	fBuscaMov()
	RBU->RBU_DTAMOV  	:=	dDataBase
	RBU->RBU_OPERAC 	:=  "3"				//1=Criação;2=Atualização;3=Ocupação;4=Congelamento;5=Cancelamento		
	RBU->RBU_CARGO		:=	RCL->RCL_CARGO 
	RBU->RBU_FUNCAO		:=	RCL->RCL_FUNCAO
	RBU->RBU_CC			:=	RCL->RCL_CC	
	RBU->RBU_SALAR		:=	RCL->RCL_SALAR 
	RBU->RBU_ENCARG		:=	RCL->RCL_ENCARG
	RBU->RBU_BENEF		:=	RCL->RCL_BENEF 
	RBU->RBU_TPCONT		:=	RCL->RCL_TPCONT
	RBU->RBU_DTINI 		:=	dDataOcupacao

	If lExistePessoa
		RBU->RBU_FILOCU		:=	cFilPessoa
		RBU->RBU_CODOCU		:=	cCodPessoa
	EndIf

	RBU->RBU_RESPON		:=	cUsername
	RBU->RBU_FILFUN		:=	cFilFun
	RBU->RBU_MATFUN		:=	cMatFun
	If cPaisLoc == "BRA"
		RBU->RBU_FGTS		:=	RCL->RCL_FGTS  
	ElseIf cPaisLoc == "MEX"	
		RBU->RBU_LOCPAG		:=	RCL->RCL_LOCPAG			
	EndIF		
	RBU->(MsUnLock())
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Gravar a ocupacao do posto								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
    RCX->(dbSetorder(4))		//RCX_FILIAL+RCX_FILFUN+RCX_MATFUN+RCX_POSTO
	RCX->(dbSeek(xFilial("RCX") + cFilFun + cMatFun + cPosto))

	RCX->(RecLock("RCX", !Found()) )
	RCX->RCX_FILIAL	:= xFilial("RCX")
	If !lCadFun
		RCX->RCX_SUBST 	:= IIf(RCL->RCL_OPOSTO < RCL->RCL_NPOSTO, "2", "1")	//1=Sim;2-Nao
	EndIf
	RCX->RCX_POSTO 	:= cPosto
	RCX->RCX_CODMOV	:= RBU->RBU_CODMOV

	If lExistePessoa
		RCX->RCX_FILOCU	:= cFilPessoa 
		RCX->RCX_CODOCU	:= cCodPessoa
	EndIf

	RCX->RCX_FILFUN	:= cFilFun
	RCX->RCX_MATFUN	:= cMatFun
	RCX->RCX_TIPOCU	:= "1"					//1=Funcionario;2=Pessoa
	RCX->RCX_DTINI	:= dDataOcupacao
	RCX->(MsUnlock())
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Atualizar o posto											   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !lCadFun .And. RCX->RCX_SUBST == "2"
		RCL->(RecLock("RCL", .F.))
		RCL->RCL_STATUS := If(RCL->RCL_STATUS=="1", "2", RCL->RCL_STATUS)	// 1=Livre;2=Ocupado;3=Congelado;4=Cancelado
		RCL->RCL_OPOSTO += 1
		RCL->(MsUnLock())
		     
		dbSelectArea("SRA")
		dbSetOrder(1)
		
		If DBSeek(cFilFun + cMatFun)		
			SRA->(RecLock("SRA", .F.))
			SRA->RA_POSTO:= RCL->RCL_POSTO
			SRA->(MsUnLock())
		EndIf
	EndIf
	
	While ( GetSX8Len() > nGetSX8Len )
		ConfirmSX8()
	End While	
	
	RestArea(aAreaRBU)
	RestArea(aAreaRCL)
	RestArea(aAreaRCX)
	RestArea(aAreaSRA)
	RestArea(aArea)
Return

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³OrgXAprova³Autor³Igor Franzoi	            ³Data³01/03/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Gravacao da operacao de movimentacao de departamento		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico													³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function OrgXAprova( cFilRBT, cCodMov, cCodOpe, nQtDig, cCodJust, lIntRSP, lPortal, cDepto )

Local nPosto	:= 0
Local nQtd		:= 0
Local nTotPos	:= 0
Local lRet		:= .F.
Local lInclui	:= .T.
Local nGetSX8Len
Local cCodPos	:= ""
Local cFieldName
Local nField
Local nCount

Default lIntRSP := .F.
Default lPortal := .F.

If ( !Empty(cCodMov) )
		
	Begin Transaction	
		nGetSX8Len:= GetSX8Len()
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o status - Legenda								     ³
		//³ 1 - baixados												 ³
		//³ 2 - Pendente parcial										 ³
		//³ 3 - Pendente total										     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		dbSelectArea("RCL")
		dbSetOrder( RetOrder("RCL","RCL_FILIAL+RCL_POSTO") )

		If nTamDpt == Nil .Or. Empty( nTamDpt )
			nTamDpt := TamSX3( "RCL_DEPTO" )[ 1 ]
		EndIf 
		
		If cDepto == Nil .Or. Empty( cDepto )
			cDepto := Space( nTamDpt )
		EndIf

		dbSelectArea("RBT")	
		dbSetOrder(RetOrder("RBT","RBT_FILIAL+RBT_DEPTO+RBT_CODMOV"))
		RBT->(dbSeek(cFilRBT + cDepto + cCodMov))
		RecLock("RBT", .F.)
		//Se nao for do portal, faz o calculo da quantidade restante
		If !lPortal
			nQtd := Orgm10Saldo(.F.)
			RBT->RBT_STATUS:= If((nQtd + nQtDig) == RBT->RBT_QTDMOV, '1', '2')
		EndIf
		cCodPos	:= RBT->RBT_CODPOS
		If ( RBT->RBT_TIPOR == "2" )						
			lInclui:= !(RCL->(DBSEEK(RBT->RBT_FILIAL+RBT->RBT_CODPOS)))
			If !lInclui
				RBT->RBT_TPOSTO := "2"	
			EndIf
		EndIf
		MsUnlock()
		//Se nao for do portal, grava o registro da movimentacao. Se for solicitacao do portal,
		//ja foi feito gravacao do registro de movimentacao
		If !lPortal
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Registro de movimentação do departamento					   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			dbSelectArea("RBX")
			RecLock("RBX",.T.)
			RBX->RBX_FILIAL	:=	xFilial("RBX")
			RBX->RBX_DEPTO 	:=	RBT->RBT_DEPTO
			RBX->RBX_CODMOV :=	cCodMov //RBT->RBT_CODMOV
			RBX->RBX_DTAMOV :=	RBT->RBT_DTAMOV
			RBX->RBX_CODOPE :=	cCodOpe //M->RBX_CODOPE	//Grava Status da Operacao: Aprovar/Cancelar/Congelar
			RBX->RBX_TPOSTO :=	RBT->RBT_TPOSTO //M->RBX_TPOSTO	//1=Individual;2=Generico
			RBX->RBX_QTDOPE	:=	nQtDig
			RBX->RBX_RESOPE	:=	cUsername
			RBX->RBX_JUSTIF := cCodJust
			MsUnLock()
		EndIf

		If RBX->RBX_CODOPE == "1"  //  Caso for Aprovado
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Registro de criacao/alteracao do posto					   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			dbSelectArea("RCL")
			If ( !lInclui )
				dbSetOrder( RetOrder("RCL","RCL_FILIAL+RCL_POSTO") )
				RCL->(dbSeek(xFilial("RCL", cFilRBT) + cCodPos))
			EndIf
			For nPosto:= 1 to nQtDig
				RecLock("RCL",lInclui)
				If lInclui
					RCL->RCL_FILIAL 	:=	RBT->RBT_FILIAL
					RCL->RCL_POSTO 		:=	RCLPostoInit()
					RCL->RCL_PROCES 	:=	RBT->RBT_PROCES
					RCL->RCL_DEPTO 		:= 	RBT->RBT_DEPTO
					RCL->RCL_CARGO 		:=	RBT->RBT_CARGO
					RCL->RCL_FUNCAO 	:=	RBT->RBT_FUNCAO
					RCL->RCL_CC			:=	RBT->RBT_CC
					RCL->RCL_SALAR   	:=	RBT->RBT_REMUNE
					RCL->RCL_ENCARG  	:= 	RBT->RBT_ENCARG
					RCL->RCL_BENEF   	:= 	RBT->RBT_BENEF
					RCL->RCL_TPCONT 	:= 	RBT->RBT_TPCONT
					RCL->RCL_STATUS 	:= 	"1"	   				//Posto Vago para ocupacao
					RCL->RCL_DTATU  	:=	dDataBase			//?? RBT->RBT_DTAMOV
		
					If cPaisLoc == "BRA"
						RCL->RCL_FGTS   := 	RBT->RBT_FGTS
					ElseIf cPaisLoc == "MEX"
						RCL->RCL_LOCPAG	:= 	RBT->RBT_LOCPAG
					EndIf
				EndIf
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Se o posto for generico cria um unico registro de posto com a³
				³ quantidade aprovada.										   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				RCL->RCL_NPOSTO 	:= 	If(RBT->RBT_TPOSTO=="2", RCL->RCL_NPOSTO+nQtDig, 1)	//1=Individual;2=Generico
				RCL->RCL_TPOSTO 	:= 	RBT->RBT_TPOSTO		//1=Individual;2=Generico
				nTotPos				:= RCL->RCL_NPOSTO
				MsUnLock()

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Integracao com Recrutamente e Selecao 					   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If lIntRSP
		
					If lInclui
						// Rotina automatica de Inclusao de Vaga
						ORGXRSPINT(3,"RCL",nQtDig)
					Endif
					
				Endif

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Registro de movimentacao do posto							   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				RecLock("RBU",.T.)
				  
				RBU->RBU_FILIAL 	:=	xFilial("RBU", RCL->RCL_FILIAL)
				RBU->RBU_POSTO 		:=	RCL->RCL_POSTO
				RBU->RBU_CODMOV		:=	fBuscaMov()
				RBU->RBU_DTAMOV  	:=	RCL->RCL_DTATU
				RBU->RBU_OPERAC 	:=  If ( lInclui, "1", "2" )					//1=Criação;2=Atualização;3=Ocupação;4=Congelamento;5=Cancelamento		
				RBU->RBU_RESPON		:=	cUserName
				RBU->RBU_ORIGEM		:=	cCodMov 		//Relacionar com o movimentacao do Departamento RBT
				RBU->RBU_NPOSTO		:=	nTotPos
				
				For nCount:= 1 To RCL->(FCount())
					cFieldName:= RCL->(FieldName(nCount))
				
					If cFieldName $ "RCL_FILIAL/RCL_POSTO/RCL_TPOSTO/RCL_NPOSTO/RCL_OPOSTO/RCL_STATUS/RCL_DTINI/RCL_DTFIM/RCL_DTATU"
						Loop
					EndIF
					
					nField:= RBU->(FieldPos(StrTran(cFieldName, "RCL", "RBU")))
				
					If nField == 0
						Loop
					EndIF
								
					RBU->(FieldPut(nField, RCL->( FieldGet(nCount) ) ) )
				Next
				
				MsUnLock()			

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Integracao com Recrutamente e Selecao 					   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If lIntRSP

					If !lInclui
						// Verifica a necessidade de envio de WF para Aprovacao com base na tabela RBU-Historico
						ORGXFUNRSP(nQtDig)
					Endif

				Endif

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Se o posto for generico cria um unico registro de posto com a³
				³ quantidade aprovada.										   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If RBT->RBT_TPOSTO == "2"	//1=Individual;2=Generico
					Exit
				EndIf
			Next nPosto
		EndIf
		lRet:=.T.
			
		While ( GetSX8Len() > nGetSX8Len )
			ConfirmSX8()
		End While	
	End Transaction

EndIf

Return ( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RD4ORGFiltro³ Autor ³Tatiane Vieira Matias³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Filtrar os departamentos de acordo com a visao Organizacio- ³±±
±±³          ³nal e operacional                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consulta Padrao RD4ORG                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RD4ORGFiltro()
	Local aArea    	:= GetArea()
	Local aAreaRDK 	:= RDK->( GetArea() )
	Local cFiltro  	:= ""     
	Local cEmpRD4  	:= ""
	Local cFilRD4  	:= ""
	Local cAliasRD4	:= GetNextAlias()
	Local cItemRD4	:= ""

	cFiltro := " (RD4_FILIAL == '" + xFilial("RD4")  + "' .AND. "
	
	dbSelectArea("RDK")	
	dbSetOrder(4)		//RDK_FILIAL+RDK_HIERAR+RDK_TIPO+RDK_CODIGO

	If RDK->( dbSeek(xFilial("RDK")+"11") )
		If Type("oGetSRA2") != "U"		//Se existir o objeto oGetSRA2, é porque esta sendo chamado da transferencia nova
			cEmpRD4 := oGetSRA2:aCols[oGetSRA2:nAt, GdFieldPos("M_EMPRESA", oGetSRA2:aHeader)] 
			cFilRD4 := xFilial("SQB", oGetSRA2:aCols[oGetSRA2:nAt, GdFieldPos("RA_FILIAL", oGetSRA2:aHeader) ] )			
		ElseIf cFuncCall $ "GPEA010|GPEA011|RSPM001|TRMA100|GPEA265" .And. cOrgCfg == "1"
			cEmpRD4 := cEmpAnt
			cFilRD4 := xFilial("SQB")
		ElseIf cFuncCall $ "GPER103"
			If RDK->( dbSeek(xFilial("RDK",cFilAnt)+"11"+MV_PAR16) )
				cEmpRD4 := cEmpAnt
				cFilRD4 := xFilial("SQB",cFilAnt)		
				cFiltro += "  RD4_CODIGO == '" + RDK->RDK_CODIGO + "' .AND. "	
			EndIf
		Else
			cEmpRD4 := cEmpAnt
			cFilRD4 := xFilial("RCL")		
			cFiltro += "  RD4_CODIGO == '" + RDK->RDK_CODIGO + "' .AND. "	
		EndIf
	EndIf

	BeginSql alias cAliasRD4
		SELECT DISTINCT RD4.RD4_CODIDE FROM %table:RD4% RD4
		WHERE RD4.RD4_FILIDE = %exp:cFilRD4% AND  RD4.RD4_EMPIDE = %exp:cEmpRD4% AND RD4.RD4_CODIGO IN (SELECT RDK.RDK_CODIGO FROM %table:RDK% RDK WHERE RDK.RDK_HIERAR = '1')
	EndSql
	
	While (cAliasRD4)->( !Eof() )
		If((Len(cItemRD4) + Len(AllTrim((cAliasRD4)->RD4_CODIDE))) < 1872) //tamanho limite para não apresentar error log de filtro
			cItemRD4 += AllTrim((cAliasRD4)->RD4_CODIDE) + '|'			
		EndIf		
		(cAliasRD4)->( DbSkip() )
	EndDo		    		
	
	(cAliasRD4)->(dbCloseArea())

	cItemRD4 := "'" + cItemRD4 + "'"

	cFiltro += " RD4_EMPIDE == '" + cEmpRD4  + "' .AND. "
	cFiltro += " RD4_FILIDE == '" + cFilRD4  + "' .AND. "
	cFiltro += " RD4_CODIDE $ " + cItemRD4 + ") "
	
	cFiltro := "@#" + cFiltro + "@#"
	
	RestArea( aAreaRDK )
	RestArea( aArea )
		
Return cFiltro

Function RCLORGFiltro()
	Local aArea    := GetArea()
	Local cFiltro  := ""     
	Local cFilRCL  := ""
	If cFuncCall $ "GPEA180|RU07T03"   
		If Type("oGetSRA2") != "U" .and. Type("oGetTran") == "U" //Se existir o objeto oGetSRA2, eh porque esta sendo chamado da transferencia nova
			cFilRCL := xFilial("RCL", oGetSRA2:aCols[oGetSRA2:nAt, GdFieldPos("RA_FILIAL", oGetSRA2:aHeader) ] )
		Elseif Type("oGetTran") != "U" 	//Se existir o objeto oGetTran, eh porque esta sendo chamado da transferencia para um unico destino
			cFilRCL := xFilial("RCL",oGetTran:aCols[oGetTran:nAt, GdFieldPos("RA_FILIAL", oGetTran:aHeader) ] )
		Else
			cFilRCL := xFilial("RCL")		
		EndIf
		cFiltro := " RCL_FILIAL == '" + cFilRCL  + "'  "
	EndIf
	
	If cFuncCall $ "GPEA010|GPEA011|RSPM001|TRMA100|GPEA265" .And. cOrgCfg == "1"
		cFilRCL := xFilial("RCL")
		
		If  Type("cDepart") != "U"
			cFiltro := " RCL_FILIAL == '" + cFilRCL + "' .And. RCL_DEPTO == '" + cDepart + "'"
		Else
			cFiltro := " RCL_FILIAL == '" + cFilRCL + "'"
		EndIf
	EndIf
	
	cFiltro := "@#" + cFiltro + "@#"
	
	RestArea( aArea )	
Return cFiltro

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ORGXRSPINT  ³ Autor ³IP - RH Inovacao     ³ Data ³ 13.02.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executar rotina automatica para inclusao/alteracao de Vagas ³±±
±±³          ³Tabela SQS                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - opcao do menu 3-Inclusao 4-Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Rotinas SIGAORG                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGXRSPINT(nOpc,cAliasInt,nQtDig)
Local aRotAuto		:= {}
Local aArea			:= GetArea()
Local cAliasQry		:= GetNextAlias()
Local cWhere		:= ""
Local nRegSQS		:= SQS->(Recno())
Local nQS_NRVAGA 	:= 0
Default nOpc 		:= 3
Default cAliasInt	:= "RCL"
Default nQtDig		:= 0

If !(cAliasInt == "RCL")
	dbSelectArea("RCL")
	dbSetOrder( RetOrder("RCL","RCL_FILIAL+RCL_POSTO") )
	dbSeek( (cAliasInt)->RCL_FILIAL+(cAliasInt)->RCL_POSTO )
Endif

If SubStr((cAliasInt)->RCL_TPOSTO, 1, 1) == '1'	// Tipo individual
	nQS_NRVAGA := (cAliasInt)->RCL_NPOSTO
Else
	nQS_NRVAGA := (cAliasInt)->RCL_NPOSTO-(cAliasInt)->RCL_OPOSTO
Endif

If nOpc == 3
	cWhere	:= "% SQS.D_E_L_E_T_ = ' ' AND SQS.QS_FILPOST = '" + (cAliasInt)->RCL_FILIAL+ "' AND SQS.QS_POSTO = '" + (cAliasInt)->RCL_POSTO +  "'%"
	BeginSql alias cAliasQry
	   	SELECT SQS.R_E_C_N_O_, SQS.QS_NRVAGA, SQS.QS_VAGAFEC
		FROM %table:SQS% SQS 
		WHERE %exp:cWhere%
		ORDER BY R_E_C_N_O_ DESC
	EndSql

	// Verifica se encontrou algum registro e se está pendente para alteracao com o numero total de vagas, senao cria um novo
	// registro no SQS apenas com o numero de vagas solicitadas
	If (cAliasQry)->( !Eof() )
		While (cAliasQry)->( !Eof() )
			If ( (cAliasQry)->QS_NRVAGA - (cAliasQry)->QS_VAGAFEC ) > 0
				SQS->( dbGoTo((cAliasQry)->(R_E_C_N_O_)) )
				nRegSQS 	:= (cAliasQry)->(R_E_C_N_O_)
				nQS_NRVAGA	:= (cAliasQry)->QS_NRVAGA + nQtDig
				nOpc 		:= 4
			Else
				nQS_NRVAGA	:= nQtDig
			Endif
			Exit
			(cAliasQry)->( dbSkip() )
		Enddo
	Endif
	
	dbCloseArea()
	dbSelectArea(cAliasInt)
Elseif  nOpc == 6	// Inclusao de Vagas apenas com qtde aprovada
	nQS_NRVAGA := nQtDig
Endif

If nOpc == 3 .Or. nOpc == 6
	Aadd( aRotAuto, { "QS_FILIAL", xFilial("SQS",(cAliasInt)->RCL_FILIAL), Nil })
	Aadd( aRotAuto, { "QS_DESCRIC", STR0010 + " " + fDesc('SQB',(cAliasInt)->RCL_DEPTO ,'SQB->QB_DESCRIC',,,1), Nil }) // "Vaga aberta para o departamento"
	Aadd( aRotAuto, { "QS_FILPOST", (cAliasInt)->RCL_FILIAL, Nil })
	Aadd( aRotAuto, { "QS_POSTO", (cAliasInt)->RCL_POSTO, Nil })
	Aadd( aRotAuto, { "QS_CC", (cAliasInt)->RCL_CC, Nil })
	Aadd( aRotAuto, { "QS_FUNCAO", (cAliasInt)->RCL_FUNCAO, Nil })
	Aadd( aRotAuto, { "QS_NRVAGA", nQS_NRVAGA, Nil })
	Aadd( aRotAuto, { "QS_SOLICIT", UsrRetName(RetCodUsr()), Nil })
	Aadd( aRotAuto, { "QS_DTABERT", DATE(), Nil })
	Aadd( aRotAuto, { "QS_TIPO", "1", Nil })

	RSP100Inc("SQS",0,nOpc,aRotAuto)
ElseIf nOpc == 4
	If ( SQS->QS_FUNCAO <> (cAliasInt)->RCL_FUNCAO .Or. SQS->QS_CC <> (cAliasInt)->RCL_CC ) 
		Aadd( aRotAuto, { "QS_FUNCAO", (cAliasInt)->RCL_FUNCAO, Nil })
		Aadd( aRotAuto, { "QS_CC", (cAliasInt)->RCL_CC, Nil })
	Else
		Aadd( aRotAuto, { "QS_NRVAGA", nQS_NRVAGA, Nil })
	Endif
	RSP100Alt("SQS",nRegSQS,nOpc,aRotAuto)
Endif

RestArea(aArea)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORGA30RSP     ºAutor  ³IP-RH Inovacao  º Data ³  09/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe Postos (ORG) associados a Vagas (RSP)   º±±
±±º          ³ e envia WF de aprovacao caso houver aumento de quadro      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ORGA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ORGXFUNRSP(nQtDig)
Local cAliasQry		:= GetNextAlias()
Local cWhere		:= ""
Default nQtDig		:= 1

cWhere	:= "% SQS.D_E_L_E_T_ = ' ' AND SQS.QS_FILPOST = '" + RBU->RBU_FILIAL+ "' AND SQS.QS_POSTO = '" + RBU->RBU_POSTO +  "'%"
BeginSql alias cAliasQry
   	SELECT SQS.R_E_C_N_O_ AS RECNO,SQS.QS_NRVAGA,SQS.QS_VAGAFEC
	FROM %table:SQS% SQS 
	WHERE %exp:cWhere%
	ORDER BY QS_VAGA DESC 
EndSql

If (cAliasQry)->( !Eof() )

	SQS->( dbGoTo( (cAliasQry)->RECNO ) )
	WFAltVagas(0,nQtDig)

	// Rotina automatica de Inclusao de Vaga
	ORGXRSPINT(3,"RCL",nQtDig)

Else
	// Inclui a vaga no RSP sem WF
	ORGXRSPINT(6,"RCL",nQtDig)
Endif

dbSelectArea(cAliasQry)
dbCloseArea()

dbSelectArea("RBU")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ORGCombo  ³ Autor ³ IP - RH Inovacao  	³ Data ³ 07.03.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com as opcoes do combo do campo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ORGCombo(cCampo)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - campo a ser selecionado para retorno do combo	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	 	 ³ SIGAORG  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Function ORGCombo(cCampo)
Local aArea    := GetArea()
Local cBox     := ""
Local aBox     := {}
Local nPosicao1:= 0
Local nPosicao2:= 0
Local cElem1 	:= cElem2:= ""
Local cIdiom	:= FWRetIdiom()        //Retorna Idioma Atual

dbSelectArea("SX3")
dbSetOrder(2)
If ( MsSeek(cCampo) )
	If cIdiom == "pt-br" 
		cBox  := SX3->X3_CBOX
	ElseIf cIdiom == 'es'
		cBox  := SX3->X3_CBOXSPA
	ElseIf cIdiom == 'en' 
		cBox  := SX3->X3_CBOXENG
	EndIf
	While ( !Empty(cBox) )
		nPosicao1   := At(";",cBox)
		If ( nPosicao1 == 0 )
			nPosicao1 := Len(cBox)+1
		EndIf
		nPosicao2   := At("=",cBox)
		cElem1 := SubStr(cBox,1,nPosicao2-1)
		cElem2 := SubStr(cBox,nPosicao2+1,nPosicao1-nPosicao2-1)
		aadd(aBox,{cElem1+' - '+cElem2,cElem1})
		cBox := SubStr(cBox,nPosicao1+1)
	EndDo
EndIf
dbSelectArea("SX3")
dbSetOrder(1)

RestArea(aArea)
Return(aBox)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³fBuscaMov³ Autor ³ Fernando Luis Guilherme³ Data ³ 10.08.20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o próximo número de código de movimento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fBuscaMov()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                       	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	 	 ³ SIGAORG  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */

Static Function fBuscaMov ()
Local aAreaRBU := RBU->(GetArea())
Local cCodMov 
Local cAliasTab:= GetNextAlias()
Local bX := .T.
Local nRbuMovTam := GetSx3Cache( "RBU_CODMOV" , "X3_TAMANHO" )

BeginSql Alias cAliasTab
		SELECT MAX(RBU_CODMOV) CODMOV  FROM  %table:RBU%  RBU
		WHERE  RBU.RBU_FILIAL = %Exp:( xFilial("RBU") )%
		AND    %NotDel%
EndSql

cCodMov := StrZero(Val((cAliasTab)->CODMOV)+1,nRbuMovTam)

//Verifico se realmente o codigo é o correto a ser utilizado de acordo com a chave primária

While bX
	If RBU -> (dbSeek(xFilial("RBU")+RCL->RCL_POSTO+cCodMov))
		cCodMov := StrZero(Val((cAliasTab)->CODMOV)+1,nRbuMovTam)
	Else
		bX:= .F.
	EndIf
End While

(cAliasTab)->(dbCloseArea())
RestArea(aAreaRBU)

Return cCodMov
