#INCLUDE "TOTVS.CH"
#INCLUDE "RHLIBUSU.CH"

Static cORGSPFL := SuperGetMv( "MV_ORGSPFL", .F., 'N' )
Static nTamPROC
Static nTamGrp

Function PosSRAUser(lShowHelp)
	Local lFound:= .F.
	Local cFuncFil
	Local cFuncMat

	Default lShowHelp:= .T.

	PswOrder(1)

	If PswSeek(__cUserId)
		cFuncFil := Subs(PswRet()[1][22],3,2)
		cFuncMat := Subs(PswRet()[1][22],5)

		If Empty(cFuncMat)
			If lShowHelp
				MsgAlert(STR0001, STR0002)		//"A matricula do funcionario nao foi definida para o usuario atual!" "Atencao!"
			EndIf
		Else
			DBSelectArea("SRA")
			DBSetOrder(1)
			lFound := DBSeek(cFuncFil + cFuncMat)
		EndIf
	EndIf
Return lFound


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ChkRh³Autor³Wagner Xavier      1a. Versao   ³Data³13/07/2000³±±
±±³          ³     ³Autor³Marinaldo de Jesus 2a. Versao   ³Data³29/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa tratamento para um determinado processo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cProcesso - determina a rotina ou Processo para Filtro      ³±±
±±³          ³cAlias    - para qual Alias                                 ³±±
±±³          ³cRetorno  - "1",Expressao Browse                            ³±±
±±³          ³          - "2",Expressao Relatorio                         ³±±
±±³          ³          - "3",Avalia expressao Browse retorna .T. OU .F.  ³±±
±±³          ³          - "4",Avalia expressao Relatorio retorna .T.OU.F. ³±±
±±³          ³          - "5",Avalia expressao Validacao retorna .T.OU.F. ³±±
±±³          ³cHelp     - nome do help quando validacao for Falsa         ³±±
±±³          ³cMsgHelp  - Mensagem Complementar para o corpo do Helo      ³±±
±±³          ³lParseSql - Realiza o parse para a query sql                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ChkRh( cProcesso , cAlias , cRetorno , cHelp , cMsgHelp, lRotCri )

Local aArea    		:= GetArea()
Local cCodUser 		:= RetCodUsr()
Local cCodUserVz	:= Space(Len(cCodUser))
Local cFilSrw  		:= xFilial( "SRW" )
Local cGrupos		:= __GRPUSER
Local cGrupoVz		:= ""
Local cProcessoVz	:= ""
Local cAliasVz		:= Space(3)
Local lFindUsr		:= .F.
Local lFindGrp 		:= .F.
Local lShowHelp		:= ( ( cHelp <> NIL ) .or. ( cMsgHelp <> NIL ) )
Local lSpFil   		:= .F.
Local aGrupos
Local cRWAlias
Local nRecno
Local uRet
Local uRetTmp
Local nPosRWSpFl	:= 0
Local cQuery   		:= ""
Local cNAlias  		:= ""
Local lGestPubl:= IIF(ExistFunc("fUsaGFP"), fUsaGFP(), .F.)

Default lRotCri		:= .F.


DEFAULT nTamPROC := 0
DEFAULT nTamGrp  := 0


If nTamProc == 0
	nTamPROC := TamSx3( "RW_PROCESS" )[ 1 ]
EndIf

If nTamGrp == 0
	nTamGrp := TamSx3( "RW_GRUPO" )[ 1 ]
EndIf
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Verificar se o Alias SRW está em uso						   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If ( Select( "SRW" ) == 0 )
	ChkFile("SRW",.F.)
	dbSelectArea("SRW")
EndIf

Begin Sequence
	nPosRWSpFl := SRW->(FieldPos("RW_SPFIL"))
	cProcesso := Padr( Alltrim( cProcesso ) , nTamProc )

	//Se nao Definiu o Tipo de Retorno abandona
	If ( cRetorno == NIL )
		uRet := .T.
		Break
	EndIf

    //Se Top e SuperFiltro o ChkRh retornara a soma de todas as restricoes
    //existentes que cabem ao usuario.
    lSpFil  		:= 	IIf(cORGSPFL=='N',.F.,FindFunction(cAlias + "SPFILTER"))

	If lSpFil .AND. (nPosRWSpFl > 0)
        cProcessoVz := "%'"+ Space(nTamProc) +"'%"
        cGruposVz	:= "%'"+ Space(nTamGrp) +"'%"
		cGrupos:=""
		aGrupos := UsrRetGrp(cUserName)
		If Len(aGrupos) > 0
			aEval( aGrupos , { |x| (  iif( Empty(cGrupos ), cGrupos := "'" + x + "'", cGrupos += ",'" + x + "'") ) } )
			cGrupos := "%" + cGrupos + "%"
		else
			cGrupos := "%'"+ Space(nTamGrp) +"'%"
		EndIf

		cNAlias := getNextAlias()
		BeginSql alias cNAlias
			SELECT RW_FILBROW, RW_FILREL, RW_VALID,RW_PROCESS
			FROM %table:SRW% SRW
			WHERE
			(
				(SRW.RW_GRUPO  = %exp:cGrupoVz%   AND SRW.RW_IDUSER = %exp:cCodUser%)
				OR
				(
					(SRW.RW_IDUSER = %exp:cCodUserVz% OR  SRW.RW_IDUSER = %exp:cCodUser%)
					AND SRW.RW_GRUPO IN (%exp:cGrupos%)
				)
				AND (SRW.RW_PROCESS = %exp:cProcessoVz% OR SRW.RW_PROCESS = %exp:cProcesso%)
			)
			AND (SRW.RW_ALIAS   = %exp:cAlias% 	OR SRW.RW_ALIAS = %exp:cAliasVz%)
			AND SRW.RW_FILIAL = %exp:cFilSrw%
			AND SRW.RW_SPFIL <> '1'
			AND	SRW.%notDel%
		EndSql

		While !(cNAlias)->(Eof())
			Do Case
				Case  !Empty((cNAlias)->RW_PROCESS) .And. (cNAlias)->RW_PROCESS <> cProcesso
					(cNAlias)->(dbSkip())
					loop
				Case ( cRetorno == "1" )	//verifica se e filtro de browse
					uRet := AllTrim( (cNAlias)->RW_FILBROW )
					If Empty( uRet )
						uRet := NIL
					EndIf
				Case ( cRetorno == "2" )  //verifica se e filtro de relatorio
					uRet := AllTrim( (cNAlias)->RW_FILREL )
					If Empty( uRet )
						uRet := NIL
					EndIf
				OtherWise
					uRet := Nil
			EndCase

			If Empty(uRetTmp) .AND. !Empty(uRet)
				uRetTmp := uRet
			ElseIf !Empty(uRetTmp) .AND. !Empty(uRet)
				uRetTmp += " .AND. " + uRet
			EndIf
			(cNAlias)->(dbSkip())
		EndDo
		(cNAlias)->(dbCloseArea())
		uRet := uRetTmp
	Else
	 	//Se o retorno da viravel __GRPUSER for vazio carrega os Grupos
		If Empty( cGrupos )
			cGrupos += "/"
			aGrupos := UsrRetGrp( cUserName )
			aEval( aGrupos , { |x| ( cGrupos += ( x + "/" ) ) } )
		EndIf

		//Procura filtro para o processo
		DBSelectArea("SRW")
		SRW->( dbSetOrder( 1 ) )
		If !( SRW->( MSSeek( cFilSrw + cProcesso + cAlias ) ) )
			If ( SRW->( dbSeek( cFilSrw + Space( TamSx3( "RW_PROCESS" )[ 1 ] ) + cAlias ) ) )
				cProcesso := Space( TamSx3( "RW_PROCESS" )[ 1 ] )
			EndIf
		EndIf

		//Percorre o Arquivo para Localizar Usuario ou Grupo 
		While SRW->( !Eof())  .And. ((cProcesso == SRW->RW_PROCESS .or. Empty(SRW->RW_PROCESS)) .And. SRW->RW_FILIAL == cFilSrw .and. cAlias = SRW->RW_ALIAS)


			//Achou o usuario
			If SRW->( !Empty( RW_IDUSER ) .and. ( RW_IDUSER == cCodUser ) )
				//Verifica se e uma restricao de superfiltro
				If nPosRWSpFl > 0
					If (SRW->RW_SPFIL != "1")
						lFindUsr := .T.
						lFindGrp := .F.
					Else
						lFindUsr := .F.
						lFindGrp := .F.
					EndIf
				else
					lFindUsr := .T.
					lFindGrp := .F.
				EndIf

				If (lFindUsr .OR.lFindGrp)
					Exit
				EndIf
			EndIf

			// Achou o grupo, mas continua para achar o usuario
			If SRW->( !Empty( RW_GRUPO ) .and. ( RW_GRUPO $ cGrupos ) )
				If nPosRWSpFl > 0
					If (SRW->RW_SPFIL != "1")
						lFindGrp := .T.
						lFindUsr := .F.
						nRecno   := SRW->( Recno() )
					EndIf
				else
					lFindGrp := .T.
					lFindUsr := .F.
					nRecno   := SRW->( Recno() )
				EndIf
			EndIf

			SRW->( dbSkip() )
		EndDo
		

		//Se Achou Processo e usuario ou achou grupo e processo
		If ( lFindUsr ) .Or. ( !lFindUsr .And. lFindGrp )

			//Se Achou no grupo seleciona registro de grupo
			If ( lFindGrp )
				SRW->( dbGoto( nRecno ) )
			EndIf

			//Obtem o Alias
			cRWAlias := SRW->RW_ALIAS

			Do Case
				//superfiltro só contempla restrições incluidas como browse, mas aplica a todos programas.
				Case ( cRetorno $ "2*4" )
					uRet := AllTrim( SRW->RW_FILREL )
					If Empty( uRet )
						uRet := NIL
						Break
					EndIf
					If ( cRetorno <> "2" .or. ( ValType( uRet ) == "C" .and. upper(left(uRet,2))=='U_' ) )
						If !( CheckExecForm( @uRet , lShowHelp ) )
							uRet	 	:= .F.
							lShowHelp	:= .F.
						EndIf
					Else
						lShowHelp := .F.
					EndIf
					Break
				Case ( cRetorno $ "1*3" )	//verifica se e filtro de browse
					uRet := AllTrim( SRW->RW_FILBROW )
					If Empty( uRet )
						uRet := NIL
						Break
					EndIf
					If ( cRetorno <> "1" .or. ( ValType( uRet ) == "C" .and. upper(left(uRet,2))=='U_' ) )
						If !( CheckExecForm( @uRet , lShowHelp ) )
							uRet		:= .F.
							lShowHelp	:= .F.
						EndIf
					Else
						lShowHelp := .F.
					EndIf
					Break
				Case ( cRetorno == "5" )
					uRet := AllTrim( SRW->RW_VALID )
			 		If Empty( uRet )
			 			uRet := NIL
			 			Break
			 		EndIf
					If !( CheckExecForm( @uRet , lShowHelp ) )
						uRet		:= .F.
						lShowHelp	:= .F.
					EndIf
					Break
				OtherWise
					Break
			EndCase

		EndIf
    EndIf

    If cRetorno == "1"	.AND. cAlias == "SRA" .AND. lGestPubl //verifica se e filtro de browse
    	If !Empty(uRet)
    		uRet += " .AND. "
    	ElseIf  Valtype(uRet) == "U"
    		uRet := ""
    	EndIf
    	If cModulo $ "GFP*VDF"
    		uRet += " (SRA->RA_REGIME == '2' )"
    	ElseIf cModulo == "GPE"
    	 	uRet += " ( SRA->RA_REGIME == '1' .OR. Empty(SRA->RA_REGIME) ) "
    	EndIf
    EndIf

End Sequence

// Caso nao exista o processo retorna F ou Brancos
DEFAULT uRet := If( ( cRetorno $ "3*4*5" ) , .F. , If( ( cRetorno == "2" ) , ".T." , " " ) )

//Mostra Help
If ( ( ValType( uRet ) == "L" ) .and. !( uRet ) )
	If ( lShowHelp )
		DEFAULT cHelp		:= "__CHKRH__"
		#IFNDEF STR0003
			#DEFINE STR0003	"Processo não autorizado pra o Usuário"
		#EndIf
		DEFAULT cMsgHelp	:= OemToAnsi( STR0003 ) //"Processo não autorizado pra o Usuário"
		Help( "" , 1 , cHelp , NIL , cMsgHelp , 1 , 0 )
	EndIf
EndIf

RestArea(aArea)

Return( uRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fChkAcessoºAutor  ³Microsiga           º Data ³  09/15/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa filtro do Controle de Acesso e Restricao na Consultaº±±
±±º          ³SXB                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fChkAcesso()
	Local lRet			:= .F.
	Static cCondicao

	If cCondicao == Nil
		cCondicao	:= &( " { || " + ChkRH( FUNNAME() , ALIAS() , If(ISINCALLSTACK("SETPRINT"), "2", "1") ) + " } " )
	EndIf
	lRet := Eval( cCondicao )

Return(If(  Valtype(lRet) =="U" ,.T. , lRet ))
//-------------------------------------------------------------------
