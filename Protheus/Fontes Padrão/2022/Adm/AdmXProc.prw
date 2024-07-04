#Include "PROTHEUS.Ch"
// Funcoes declaradas e usadas em procedures, que necessitam 
// ser prefixadas no AS400 com o nome do banco ( schema ) 
// ( array usado na aplicacao de stored procedures ) 
Static a400Funcs := { "MSDATEDIFF" , "MSDATEADD" }

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbAjustaP³ Autor ³                       ³ Data ³ 28/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz validacoes nas procedures antes e depois da procedures ³±±
±±³          ³ passarem pela funca MsParse                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbAjustaP()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cQuery = procedure ajustada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lAntesParser =.t. antes da Msparse, .F. depois da funca    ³±±
±±³          ³ cQueryParser = query a ser ajustada                        ³±±
±±³          ³ nTratRec = posicao em q o recno deve ser tratado           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbAjustaP(lAntesParser, cQuery, nPTratRec)
Local aSaveArea   := GetArea()
Local nPosFim     := 0
Local nPosFim2	  := 0
Local nPos2       := 0
Local nPos3       := 0
Local nCnt01      := 0
Local nCaracter   := 0
Local cRecnotext  := ""
Local cInsertText := ""
Local cBufferAux  := ""
Local xProc       := ""
Local nPosAux     := 0
Local cNumField   := ""
Local nPosIni     := 0
Local cCampo      := ''
Local lMantem     :=.T.
Local cTabela     := ''
Local cChaveUnica := ''
*/
//nPTratRec	      := If( nPTratRec = NIL, 0, nTratRec )
default nPTratRec = 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacoes que devem ser feitas/adicionadas ANTES da query ( procedure ) passar pela funcao MsParses ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAntesParser
	/* ---------------------------------------------------------------------
		TRATAMENTO PARA GRAVAR REGISTROS SIMULTANEAMENTE NA MESMA TABELA.                                
		##TRATARECNO nRecno
			codigo 
			Insert Into Recno values ;
	   			 	codigo
		##FIMTRATARECNO
	   ---------------------------------------------------------------------- */
	While ("##TRATARECNO" $ Upper(cQuery))
		nPTratRec	:= AT("##TRATARECNO",Upper(cQuery))
		nPosFim		:= AT("\",Upper(cQuery))  
		 //Retorna a variavel recno a ser aplicada no insert
		cRecnotext	:= Substr(cQuery,nPTratRec+13,nPosFim-nPTratRec-13)
		nPosFim2	:= AT("##FIMTRATARECNO", Upper(cQuery))
		//Retorna o INSERT para ser utilizado no tratamento.
		cInsertText	:= Substr( cQuery, nPosFim+1,nPosFim2-nPosFim-1)
		//Seta as variaveis @ins_ini e @ins_fim, que serao utilizadas como marcador inicial e final no tratamento de INSERT.
		cBufferAux	:= "select @ins_ini = " + cRecnotext + CRLF
		cBufferAux	+= cInsertText + CRLF
		cBufferAux	+= "select @ins_fim = 1 " + CRLF
		cQuery 	:= Stuff( cQuery, nPTratRec,((nPosFim2+15)-nPTratRec),cBufferAux ) // Retira ##TRATARECNO e Inclui o Tratamento de Insert no cBuffer
	End While
	
	//Inclui declaracao de variaveis utilizadas para o tratamento de INSERT na procedure
	If nPTratRec <> 0
		nPos3 := at("BEGIN",upper(cQuery))
		If nPos3 > 0
			cInsertText := "Declare @iLoop integer " + CRLF
			cInsertText += "Declare @ins_error integer " + CRLF
			cInsertText += "Declare @ins_ini integer " + CRLF
			cInsertText += "Declare @ins_fim integer " + CRLF
			cInsertText += "Declare @icoderror integer " + CRLF
			cQuery	:= Stuff(cQuery,(nPos3-2),0,cInsertText)
		Endif
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o campos utilizado existe na tabela para a criacao d procedure  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ("##FIELDP" $ Upper(cQuery))
		nPosAux   := AT("##FIELDP",Upper(cQuery))
		cNumField := substr(cQuery,nPosAux + 8,2) 
		nPosIni   := AT("##FIELDP" + cNumField +"( '", Upper(cQuery))
		nPosFim   := AT("##ENDFIELDP" + cNumField, Upper(cQuery))
		cCampo    := ''
		lMantem   :=.T.
		// Verifica se os campos existem no banco 
		For nPos2 := nPosIni+13 to Len( cQuery )
			If substr( cQuery, nPos2, 1) != "'" .and. substr( cQuery, nPos2, 1) != ";".and. substr( cQuery, nPos2, 1) != "."
				cCampo += substr( cQuery, nPos2, 1)
			Elseif substr( cQuery, nPos2, 1) = "."
				cTabela := cCampo
				If !EMPTY(FWX2CHAVE(cTabela))
	     			lMantem := .f.
	     			exit
				EndIf
				cCampo := ''
			Else
				If !EMPTY(FWX2CHAVE(cTabela))
	  			   ChkFile(cTabela, .F.)
	  				If cCampo <> "R_E_C_D_E_L_"                 
						lMantem := lMantem .and. ((cTabela)->(FieldPos( cCampo )) > 0)
						cCampo := ''
					else
						cChaveUnica := tcInternal(13, Alltrim(FWX2UNICO(cTabela)))
	  					If Empty(cChaveUnica)
	  						lMantem := .f.
	  						cCampo := ''
	  					else
	  						lMantem := .t.
	  						cCampo := ''
	  					EndIf
	  				EndIf
				EndIf
			EndIf
			If substr( cQuery, nPos2, 1) = "'"
				EXIT
			EndIf
		Next
		If !lMantem
			// os marcadores e todo o código contido entre eles serão removidos 
			cQuery:= Substr( cQuery, 1, nPosIni-1 )+ Substr( cQuery, nPosFim+13 )
		Else
			// Retira apenas as instrucoes #FIELDP  e ##ENDFIELDP
			cQuery:= Substr( cQuery, 1, nPosIni-1 ) + Substr( cQuery, nPos2 + 3, nPosfim - nPos2 - 3 ) + Substr( cQuery, nPosfim+13 )
		EndIf
	End While  

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacoes que devem ser feitas APOS a query ( procedure ) passar pela funcao MsParse ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If Trim(TcGetDb()) = 'INFORMIX'                         
		cQuery := StrTran(cQuery, 'LET viTranCount  = 0', "COMMIT WORK")
		cQuery := StrTran(cQuery, 'LTRIM ( RTRIM (', "TRIM((")
	EndIf
	
	//Efetua tratamento para o DB2 ou AS400
	If Trim(TcGetDb()) = 'DB2'
		cQuery	:= StrTran( cQuery, 'set vfim_CUR  = 0 ;', 'set fim_CUR = 0;' )
		cQuery	:= StrTran( cQuery, "IF fim_CUR <> 1 THEN", "IF fim_CUR = 1 THEN")
	elseIf  Trim(TcGetDb()) = 'ORACLE'
		cQuery	:= StrTran( cQuery, "CUR_PCO300%NOTFOUND1", "CUR_PCO300%NOTFOUND")
	EndIf

	//Inclusao do tratamento de INSERT na procedure
	If nPTratRec <> 0
		cQuery	:= InsertPutSql( TcGetDb(), cQuery )
		If Trim(TcGetDb()) = 'DB2'
			nPos3 := at("DECLARE FIM_CUR INTEGER DEFAULT 0;",upper(cQuery))
			If nPos3 > 0
				cInsertText := "Declare fim_CUR integer default 0;" + CRLF
				cInsertText += "Declare v_dup_key CONDITION for sqlstate '23505';" + CRLF
				cQuery	:= Stuff(cQuery,nPos3,34,cInsertText)
			Endif
			nPos3 := at("SET FIM_CUR = 1;",upper(cQuery))
			If nPos3 > 0        
				cInsertText := "SET fim_CUR = 1;" + CRLF
				cInsertText += "DECLARE CONTINUE HANDLER FOR v_dup_key SET vicoderror = 1;" + CRLF
				cQuery	:= Stuff(cQuery,nPos3,16,cInsertText)
			Endif
		EndIf
	EndIf
	
	xProc := ''
	For nCnt01 := 1 to Len(cQuery)
	    nCaracter := asc(Substr(cQuery,nCnt01,1))
	    if nCaracter == 13 
	       xProc += ''
	    elseif nCaracter == 10
	       xProc +=chr(10)
	    else 
	       xProc += Subs(cQuery,nCnt01,1)
	    endif
	Next
	cQuery:=xProc
	// na validaproc
	If Upper(TcSrvType())= "ISERIES" .and. !Empty(cQuery)
		cQuery := pVldDb2400( cQuery )   //pcoxfun
	EndIf
Endif

RestArea(aSaveArea)
Return( cQuery)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcSTRZERO ³ Autor ³ Alice Y Y             ³ Data ³ 15.01.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procedure MSSTRZERO                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMsStrZero - Nome com que a MsStrZero sera criada             ³±±
±±³          ³ Utilizar um nome diferente MSSTRZERO, este e o do pac de proc ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xProc = procedure ajustada                                   ³±±
±±³          ³ cNome = Nomeda procedureada                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ProcSTRZERO(cMsStrZero)
Local cProc :=""
Local xProc:=''
Local nCaracter := 0
Local nCnt01 := 0

/* ------------------------------------------------------------------------------
	--    Procedure   -  Converte valor num‚rico Inteiro para String 
	--            		   com zeros … esquerda ( Como a StrZero )     
	--    Entrada     -  IN_VALOR   : Valor a ser Convertido         
	--                -  IN_INTEGER : Numero de Casas Inteiras       
	--    Saida       -  OUT_VALOR  : Valor de Retorno Tipo Char     
	---------------------------------------------------------------------------- */
If Alltrim(Upper(TcGetDb()))=="INFORMIX"
	cProc:="create procedure "+cMsStrZero+"_"+cEmpAnt+" (" +CRLF
	cProc+="   IN_VALOR Integer , " +CRLF
	cProc+="   IN_INTEGER Integer ) " +CRLF
	    
	cProc+="   Returning  VarChar( 100 ) ;" +CRLF         
	
	cProc+="   Define OUT_VALOR VarChar( 100 ); " +CRLF
	cProc+="   begin " +CRLF
	cProc+="      Let OUT_VALOR = Substr(RPAD('0',IN_INTEGER,'0')||IN_VALOR,(length(RPAD('0',IN_INTEGER,'0')||IN_VALOR)-IN_INTEGER)+1,IN_INTEGER);" +CRLF
	cProc+="      Return  OUT_VALOR;" +CRLF
	cProc+="   end" +CRLF
	cProc+="end procedure;" +CRLF
ElseIf Alltrim(Upper(TcGetDb()))=="ORACLE"
	cProc:="create or replace procedure "+cMsStrZero+"_"+cEmpAnt+" (" +CRLF
	cProc+="   IN_VALOR  in   Integer , " +CRLF
	cProc+="   IN_INTEGER  in   Integer , " +CRLF
	cProc+="   OUT_VALOR  out  Char ) is " +CRLF
	cProc+="begin" +CRLF
	cProc+="   OUT_VALOR  :=  (Substr ( RPAD ( '0' , IN_INTEGER ,'0' ) || To_Char(IN_VALOR ),(length(RPAD ( '0' , IN_INTEGER ,'0' ) || To_Char(IN_VALOR )" +CRLF
	cProc+="          )-IN_INTEGER )+1, IN_INTEGER )) ;" +CRLF
	cProc+="end;" +CRLF

ElseIf Alltrim(Upper(TcGetDb()))=="DB2" .or. Alltrim(Upper(TcGetDb()))=="DB2/400"
	cProc:="create procedure "+cMsStrZero+"_"+cEmpAnt+CRLF
	cProc+="(" +CRLF
	cProc+="in  IN_VALOR    integer ," +CRLF
	cProc+="in  IN_INTEGER  integer ," +CRLF
	cProc+="out OUT_VALOR   char( 254 )" +CRLF
	cProc+=")" +CRLF
	cProc+="language SQL" +CRLF
	cProc+="begin" +CRLF
	cProc+="declare vAux   varchar( 254 );" +CRLF
	cProc+="set vAux = repeat( '0', IN_INTEGER ) || RTrim( Char( IN_VALOR ) );" +CRLF
	cProc+="set OUT_VALOR = Substr( vAux, ( length( vAux ) - IN_INTEGER ) + 1, IN_INTEGER );" +CRLF
	cProc+="end" +CRLF
ElseIf Alltrim(Upper(TcGetDb()))=="SYBASE" .or. "MSSQL" $ Alltrim(Upper(TcGetDb()))
	cProc:="create procedure "+cMsStrZero+"_"+cEmpAnt+" (" +CRLF
	cProc+="    @IN_VALOR Integer , " +CRLF
	cProc+="    @IN_INTEGER Integer , " +CRLF
	cProc+="    @OUT_VALOR VarChar( 100 )  output ) as  " +CRLF
	cProc+="begin" +CRLF
	cProc+="   Select @OUT_VALOR  =  (Right ( Replicate ( '0' , @IN_INTEGER ) + Convert( VarChar( 255 ) ,@IN_VALOR ), @IN_INTEGER )) " +CRLF
	cProc+="end " +CRLF
ElseIf Alltrim(Upper(TcGetDb()))=="POSTGRES"
	cProc += "------------------------------------------------------------------------------ "+CRLF
	cProc += "--    Procedure   -  Converte valor numerico Inteiro para String  "+CRLF
	cProc += "--            		 com zeros a esquerda ( identico a StrZero ) "+CRLF     
	cProc += "--    Entrada     -  IN_VALOR   : Valor a ser Convertido "+CRLF         
	cProc += "--                -  IN_INTEGER : Numero de Casas Inteiras "+CRLF       
	cProc += "--    Saida       -  OUT_VALOR  : Valor de Retorno Tipo Char "+CRLF     
	cProc += "--    Responsavel :  Totvs by Emerson Rony"+CRLF         		       
	cProc += "--    Data        :  30/11/2016 "+CRLF                                
	cProc += "---------------------------------------------------------------------------- "+CRLF 
	cProc += "CREATE OR REPLACE FUNCTION "+cMsStrZero+"_"+cEmpAnt+" "+CRLF
	cProc += "( "+CRLF
	cProc += "	IN_VALOR    integer , "+CRLF
	cProc += "	IN_INTEGER  integer , "+CRLF
	cProc += "	OUT OUT_VALOR   varchar( 254 ) "+CRLF
	cProc += ") AS $$ "+CRLF
	cProc += " "+CRLF
	cProc += "DECLARE "+CRLF 
	cProc += " vAux   varchar( 254 ) ; "+CRLF
	cProc += " "+CRLF
	cProc += "BEGIN "+CRLF
	cProc += " "+CRLF
	cProc += "	vAux := CONCAT( REPEAT ( '0', IN_INTEGER ), TRIM ( TO_CHAR( IN_VALOR, '999' ) ) ); "+CRLF
	cProc += "	OUT_VALOR := SUBSTR ( vAux, ( LENGTH ( vAux ) - IN_INTEGER ) + 1, IN_INTEGER ) ; "+CRLF
	cProc += " "+CRLF
	cProc += "END $$ LANGUAGE 'plpgsql' "+CRLF

EndIf

xProc := ''
For nCnt01 := 1 to Len(cProc)
    nCaracter := asc(Substr(cProc,nCnt01,1))
    if nCaracter == 13
       xProc += ''
    elseif nCaracter == 10
       xProc +=chr(10)
    else 
       xProc += Subs(cProc,nCnt01,1)
    endif
Next

Return(xProc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³cProcSOMA1    ºAutor ³ TOTVS            º Data ³  23/01/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera mssoma1 para banco respectivo                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Nome que teráa procedure SOMA1                     º±±
±±º          ³ EXPC2 - Nome MSSTRZERO criada ja criada q será usada aqui  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ cQuery = Query com script do MSSoma1                       ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function cProcSOMA1(cSoma1, cStrZero)
Local aSaveArea := GetArea()
Local cQuery    := ""
Local xProc     := ""
Local nCnt01    := 0
Local nCaracter := 0

If "MSSQL" $ Upper(Trim(TcGetDb())) .or. Upper(Trim(TcGetDb())) = "SYBASE"
	cQuery := "create procedure "+cSoma1+"_"+cEmpAnt+" ("+CRLF
	cQuery += "  @IN_SOMAR      VarChar(100),"+CRLF
	cQuery += "  @IN_SOMALOW    Char(01),"+CRLF
	cQuery += "  @OUT_RESULTADO VarChar(100) OutPut"+CRLF
	cQuery += ")"+CRLF
	cQuery += "as"+CRLF
	/* ------------------------------------------------------------------------------------
	    Procedure       -     Soma1
	    Descricao       - <d> Soma 1 numa string qualquer </d>
	    Entrada         - <ri> @IN_SOMAR      - String a qual será somado 1
	                           @IN_SOMALOW    - Considera letras minúsculas </ri>
	    Saida           - <ro> @OUT_RESULTADO - String somada de 1 </ro>
	-------------------------------------------------------------------------------------- */
	
	cQuery += "Declare @iAux     integer"+CRLF
	cQuery += "Declare @iTamOri  integer"+CRLF
	cQuery += "Declare @iNx      integer"+CRLF
	cQuery += "Declare @cNext    Char(01)"+CRLF
	cQuery += "Declare @cSpace   Char(01)"+CRLF
	cQuery += "Declare @cRef     VarChar(1)"+CRLF
	cQuery += "Declare @cResult  VarChar(100)"+CRLF
	cQuery += "Declare @iTamStr  integer"+CRLF
	
	cQuery += "begin"+CRLF
   /*---------------------------------------------------------------------------------
     @IN_SOMAR é somado com '#', pois no SQLServer, mesmo que o parâmetro seja declarado
     como VarChar, qdo aplico a funçao Len numa var que contém '999 ' , a função Len 
     retorna 3 e não 4
     ---------------------------------------------------------------------------------*/
	cQuery += "   select @iTamStr = ( Len( @IN_SOMAR + '#' ) - 1 )"+CRLF
	cQuery += "   select @iTamOri = ( Len( @IN_SOMAR + '#' ) - 1 )"+CRLF
	cQuery += "   select @iAux = 1"+CRLF
	cQuery += "   select @iNx  = 1"+CRLF
	cQuery += "   select @cRef = ' '"+CRLF
	cQuery += "   select @cNext   = '0'"+CRLF
	cQuery += "   select @cSpace  = '0'"+CRLF
	cQuery += "   select @cResult = ' '"+CRLF
    
	cQuery += "   If Len(Rtrim(@IN_SOMAR)) = 0 begin"+CRLF
      /*-----------------------------------------------------------------------
        @IN_SOMAR -> com tamanho zero
        -----------------------------------------------------------------------*/
	cQuery += "      Exec "+cStrZero+" @iAux, @iTamStr , @OUT_RESULTADO OutPut"+CRLF
	cQuery += "   end"+CRLF
	cQuery += "   else if @IN_SOMAR = Replicate( '*', @iTamOri) begin"+CRLF
      /*-----------------------------------------------------------------------
         @IN_SOMAR = '*********'
        -----------------------------------------------------------------------*/
	cQuery += "      select @OUT_RESULTADO = @IN_SOMAR"+CRLF
      
	cQuery += "   end"+CRLF
	cQuery += "   else begin"+CRLF
      /*-----------------------------------------------------------------------
        @IN_SOMAR -> Cjto de Caracteres
        -----------------------------------------------------------------------*/
	cQuery += "      While @iTamStr >= @iNx begin"+CRLF
	cQuery += "         select @cRef = Substring(  @IN_SOMAR + '#' , @iTamStr , 1 )"+CRLF
	cQuery += "         if @cRef = ' ' begin"+CRLF
	cQuery += "            select @cResult = ' ' + @cResult"+CRLF
	cQuery += "            select @cNext = '1'"+CRLF
	cQuery += "            select @cSpace = '1'"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if @IN_SOMAR = ( Replicate('z',  @iTamOri )) begin"+CRLF
	cQuery += "            select @cResult = ( Replicate('*',  @iTamOri ))"+CRLF
	cQuery += "            break"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if @cRef < '9' begin"+CRLF
	cQuery += "            select @cResult = Substring( @IN_SOMAR, 1, ( @iTamStr - 1) ) + Char( Ascii( @cRef ) + 1 ) + @cResult"+CRLF
	cQuery += "            select @cNext = '0'"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if ( @cRef = '9' and @iTamStr > 1 ) begin"+CRLF
	cQuery += "            If ( Substring( @IN_SOMAR,  @iTamStr - 1 ,1 ) <= '9'  and  Substring( @IN_SOMAR, @iTamStr - 1 ,1 ) <> ' ') begin"+CRLF
	cQuery += "               select @cResult = '0' + @cResult"+CRLF
	cQuery += "               select @cNext = '1'"+CRLF
	cQuery += "            end"+CRLF
	cQuery += "            else if ( Substring( @IN_SOMAR, ( @iTamStr -1 ), 1 ) = ' ' ) begin"+CRLF
	cQuery += "               select @cResult = Substring( @IN_SOMAR,1,( @iTamStr - 2 ) ) + '10' + @cResult"+CRLF
	cQuery += "               select @cNext = '0'"+CRLF
	cQuery += "            end"+CRLF
	cQuery += "            else begin"+CRLF
	cQuery += "               select @cResult = Substring( @IN_SOMAR, 1, ( @iTamStr - 1 ) ) + 'A' + @cResult"+CRLF
	cQuery += "               select @cNext = '0'"+CRLF
	cQuery += "            end"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if @cRef = '9' and ( @iTamStr = 1 ) and ( @cSpace = '1' ) begin"+CRLF
	cQuery += "            select @cResult = '10' + Substring( @cResult, 1, ( Len( @cResult + '#' ) - 1) )"+CRLF
	cQuery += "            select @cNext = '0'"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if @cRef = '9' and @iTamStr = 1 and @cSpace = '0' begin"+CRLF
	cQuery += "            select @cResult = 'A' + @cResult"+CRLF
	cQuery += "            select @cNext ='0'"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if @cRef > '9' and @cRef < 'Z' begin"+CRLF
	cQuery += "            select @cResult = Substring( @IN_SOMAR, 1, ( @iTamStr - 1 ) ) + Char( ( Ascii( @cRef )+ 1 ) ) + @cResult"+CRLF
	cQuery += "            select @cNext = '0'"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if @cRef > 'Z' and @cRef < 'z' begin"+CRLF
	cQuery += "            select @cResult = Substring( @IN_SOMAR, 1, ( @iTamStr - 1 )) + Char((Ascii( @cRef ) + 1)) + @cResult"+CRLF
	cQuery += "            select @cNext = '0'"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if @cRef = 'Z' and @IN_SOMALOW = '1' begin"+CRLF
	cQuery += "            select @cResult = Substring( @IN_SOMAR, 1, ( @iTamStr - 1 )) + 'a' + @cResult"+CRLF
	cQuery += "            select @cNext = '0'"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if ( @cRef='z' or @cRef = 'Z') and @cSpace = '1' begin"+CRLF
	cQuery += "            select @cResult = Substring( @IN_SOMAR, 1, @iTamStr ) + '0' + Substring( @cResult, 1, ( Len( @cResult +'#' ) - 2 ))"+CRLF
	cQuery += "            select @cNext = '0'"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         else if @cRef = 'z' or @cRef = 'Z' begin"+CRLF
	cQuery += "            select @cResult = '0' + @cResult"+CRLF
	cQuery += "            select @cNext = '1'"+CRLF
	cQuery += "         end"+CRLF
	cQuery += "         if @cNext = '0' break"+CRLF
	cQuery += "         select @iTamStr = @iTamStr - 1"+CRLF
	cQuery += "      End"+CRLF
	cQuery += "      select @OUT_RESULTADO = @cResult"+CRLF
	cQuery += "   end"+CRLF
	cQuery += "end"+CRLF
	
ElseIf Upper(Trim(TcGetDb())) = "ORACLE"
	cQuery := "create procedure "+cSoma1+"_"+cEmpAnt+" ("+CRLF
	cQuery += "IN_SOMAR      in VARCHAR,"+CRLF
	cQuery += "IN_SOMALOW    in CHAR,"+CRLF
	cQuery += "OUT_RESULTADO out VARCHAR) IS"+CRLF
	
	cQuery += "  viAux    INTEGER;"+CRLF
	cQuery += "  viTamOri INTEGER;"+CRLF
	cQuery += "  viNx     INTEGER;"+CRLF
	cQuery += "  vcNext   CHAR(01);"+CRLF
	cQuery += "  vcSpace  CHAR(01);"+CRLF
	cQuery += "  vcRef    VARCHAR(1);"+CRLF
	cQuery += "  vcResult VARCHAR(100);"+CRLF
	cQuery += "  viTamStr INTEGER;"+CRLF
	cQuery += "BEGIN"+CRLF
	cQuery += "  viTamStr := (LENGTH(IN_SOMAR || '#') - 1);"+CRLF
	cQuery += "  viTamOri := (LENGTH(IN_SOMAR || '#') - 1);"+CRLF
	cQuery += "  viAux    := 1;"+CRLF
	cQuery += "  viNx     := 1;"+CRLF
	cQuery += "  vcRef    := ' ';"+CRLF
	cQuery += "  vcNext   := '0';"+CRLF
	cQuery += "  vcSpace  := '0';"+CRLF
	cQuery += "  vcResult := '';"+CRLF
	cQuery += "  IF LENGTH(RTRIM(IN_SOMAR)) = 0 THEN"+CRLF
	cQuery += "    "+cStrZero+"(viAux,viTamStr,OUT_RESULTADO);"+CRLF
	cQuery += "    OUT_RESULTADO := ' ';"+CRLF
	cQuery += "  ELSE"+CRLF
	cQuery += "    IF IN_SOMAR = RPAD('*',viTamOri,'*') THEN"+CRLF
	cQuery += "      OUT_RESULTADO := IN_SOMAR;"+CRLF
	cQuery += "    ELSE"+CRLF
	cQuery += "      <<parse1>>"+CRLF
	cQuery += "      WHILE (viTamStr >= viNx) LOOP"+CRLF
	cQuery += "        vcRef := SUBSTR(IN_SOMAR || '#',viTamStr,1);"+CRLF
	cQuery += "        IF vcRef = ' ' THEN"+CRLF
	cQuery += "          vcResult := ' ' || vcResult;"+CRLF
	cQuery += "          vcNext   := '1';"+CRLF
	cQuery += "          vcSpace  := '1';"+CRLF
	cQuery += "        ELSE"+CRLF
	cQuery += "          IF IN_SOMAR = (RPAD('z',viTamOri,'z')) THEN"+CRLF
	cQuery += "            vcResult := (RPAD('*',viTamOri,'*'));"+CRLF
	cQuery += "            EXIT;"+CRLF
	cQuery += "          ELSE"+CRLF
	cQuery += "            IF vcRef < '9' THEN"+CRLF
	cQuery += "              vcResult := SUBSTR(IN_SOMAR,1,(viTamStr - 1)) ||"+CRLF
	cQuery += "                          CHR(ASCII(vcRef) + 1) || vcResult;"+CRLF
	cQuery += "              vcNext   := '0';"+CRLF
	cQuery += "            ELSE"+CRLF
	cQuery += "              IF (vcRef = '9' and viTamStr > 1) THEN"+CRLF
	cQuery += "                IF (SUBSTR(IN_SOMAR,viTamStr - 1,1) <= '9' and"+CRLF
	cQuery += "                   SUBSTR(IN_SOMAR,viTamStr - 1,1) <> ' ') THEN"+CRLF
	cQuery += "                  vcResult := '0' || vcResult;"+CRLF
	cQuery += "                  vcNext   := '1';"+CRLF
	cQuery += "                ELSE"+CRLF
	cQuery += "                  IF (SUBSTR(IN_SOMAR,(viTamStr),1) = ' ') THEN"+CRLF
	cQuery += "                    vcResult := SUBSTR(IN_SOMAR,1,(viTamStr - 2)) || '10' ||"+CRLF
	cQuery += "                                vcResult;"+CRLF
	cQuery += "                    vcNext   := '0';"+CRLF
	cQuery += "                  ELSE"+CRLF
	cQuery += "                    vcResult := SUBSTR(IN_SOMAR,1,(viTamStr - 1)) || 'A' ||"+CRLF
	cQuery += "                                vcResult;"+CRLF
	cQuery += "                    vcNext   := '0';"+CRLF
	cQuery += "                  END IF;"+CRLF
	cQuery += "                END IF;"+CRLF
	cQuery += "              ELSE"+CRLF
	cQuery += "                IF vcRef = '9' and (viTamStr = 1) and (vcSpace = '1') THEN"+CRLF
	cQuery += "                  vcResult := '10' ||"+CRLF
	cQuery += "                              SUBSTR(vcResult,"+CRLF
	cQuery += "                                     1,"+CRLF
	cQuery += "                                     (LENGTH(vcResult || '#') - 1));"+CRLF
	cQuery += "                  vcNext   := '0';"+CRLF
	cQuery += "                ELSE"+CRLF
	cQuery += "                  IF vcRef = '9' and viTamStr = 1 and vcSpace = '0' THEN"+CRLF
	cQuery += "                    vcResult := 'A' || vcResult;"+CRLF
	cQuery += "                    vcNext   := '0';"+CRLF
	cQuery += "                  ELSE"+CRLF
	cQuery += "                    IF vcRef > '9' and vcRef < 'Z' THEN"+CRLF
	cQuery += "                      vcResult := SUBSTR(IN_SOMAR,1,(viTamStr - 1)) ||"+CRLF
	cQuery += "                                  CHR((ASCII(vcRef) + 1)) || vcResult;"+CRLF
	cQuery += "                      vcNext   := '0';"+CRLF
	cQuery += "                    ELSE"+CRLF
	cQuery += "                      IF vcRef > 'Z' and vcRef < 'z' THEN"+CRLF
	cQuery += "                        vcResult := SUBSTR(IN_SOMAR,1,(viTamStr - 1)) ||"+CRLF
	cQuery += "                                    CHR((ASCII(vcRef) + 1)) || vcResult;"+CRLF
	cQuery += "                        vcNext   := '0';"+CRLF
	cQuery += "                      ELSE"+CRLF
	cQuery += "                        IF vcRef = 'Z' and IN_SOMALOW = '1' THEN"+CRLF
	cQuery += "                          vcResult := SUBSTR(IN_SOMAR,1,(viTamStr - 1)) || 'a' ||"+CRLF
	cQuery += "                                      vcResult;"+CRLF
	cQuery += "                          vcNext   := '0';"+CRLF
	cQuery += "                        ELSE"+CRLF
	cQuery += "                          IF (vcRef = 'z' or vcRef = 'Z') and vcSpace = '1' THEN"+CRLF
	cQuery += "                            vcResult := SUBSTR(IN_SOMAR,1,viTamStr) || '0' ||"+CRLF
	cQuery += "                                        SUBSTR(vcResult,"+CRLF
	cQuery += "                                               1,"+CRLF
	cQuery += "                                               (LENGTH(vcResult || '#') - 2));"+CRLF
	cQuery += "                            vcNext   := '0';"+CRLF
	cQuery += "                          ELSE"+CRLF
	cQuery += "                            IF vcRef = 'z' or vcRef = 'Z' THEN"+CRLF
	cQuery += "                              vcResult := '0' || vcResult;"+CRLF
	cQuery += "                              vcNext   := '1';"+CRLF
	cQuery += "                            END IF;"+CRLF
	cQuery += "                          END IF;"+CRLF
	cQuery += "                        END IF;"+CRLF
	cQuery += "                      END IF;"+CRLF
	cQuery += "                    END IF;"+CRLF
	cQuery += "                  END IF;"+CRLF
	cQuery += "                END IF;"+CRLF
	cQuery += "              END IF;"+CRLF
	cQuery += "            END IF;"+CRLF
	cQuery += "          END IF;"+CRLF
	cQuery += "        END IF;"+CRLF
	cQuery += "        IF vcNext = '0' THEN"+CRLF
	cQuery += "          EXIT;"+CRLF
	cQuery += "        END IF;"+CRLF
	cQuery += "        viTamStr := viTamStr - 1;"+CRLF
	cQuery += "      END LOOP;"+CRLF
	cQuery += "      OUT_RESULTADO := vcResult;"+CRLF
	cQuery += "    END IF;"+CRLF
	cQuery += "  END IF;"+CRLF
	cQuery += "END;"+CRLF

ElseIf Upper(Trim(TcGetDb())) = "DB2"
	cQuery := "create procedure "+cSoma1+"_"+cEmpAnt+" ("+CRLF
	cQuery += " IN IN_SOMAR VARCHAR( 100 ) , "+CRLF
	cQuery += " IN IN_SOMALOW CHAR( 01 ) , "+CRLF
	cQuery += " OUT OUT_RESULTADO VARCHAR( 100 ) "+CRLF
	cQuery += ")"+CRLF
 	
	cQuery += "LANGUAGE SQL"+CRLF
 	
	cQuery += "BEGIN"+CRLF
	cQuery += " declare vIAUX INTEGER ;"+CRLF
	cQuery += " declare vITAMORI INTEGER ;"+CRLF
	cQuery += " declare vINX INTEGER ;"+CRLF
	cQuery += " declare vCNEXT CHAR( 01 ) ;"+CRLF
	cQuery += " declare vCSPACE CHAR( 01 ) ;"+CRLF
	cQuery += " declare vCREF VARCHAR( 1 ) ;"+CRLF
	cQuery += " declare vCRESULT VARCHAR( 100 ) ;"+CRLF
	cQuery += " declare vITAMSTR INTEGER ;"+CRLF
	cQuery += " declare vSTRBASE VARCHAR(62) ;"+CRLF
	cQuery += " set vSTRBASE = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' ;"+CRLF
 	
	cQuery += " set vITAMSTR  =  (LENGTH ( IN_SOMAR  || '#' ) - 1 ) ;"+CRLF
	cQuery += " set vITAMORI  =  (LENGTH ( IN_SOMAR  || '#' ) - 1 ) ;"+CRLF
	cQuery += " set vIAUX  = 1 ;"+CRLF
	cQuery += " set vINX  = 1 ;"+CRLF
	cQuery += " set vCREF  = ' ' ;"+CRLF
	cQuery += " set vCNEXT  = '0' ;"+CRLF
	cQuery += " set vCSPACE  = '0' ;"+CRLF
	cQuery += " set vCRESULT  = ' ' ;"+CRLF
	cQuery += " IF LENGTH ( RTRIM ( IN_SOMAR )) = 0  THEN "+CRLF
	cQuery += "  CALL "+cStrZero+" (vIAUX , vITAMSTR , OUT_RESULTADO );"+CRLF
	cQuery += " ELSE "+CRLF
	cQuery += "  IF IN_SOMAR  = REPEAT( '*' , vITAMORI) THEN "+CRLF
	cQuery += "   set OUT_RESULTADO  = IN_SOMAR ;"+CRLF
	cQuery += "  ELSE "+CRLF
	cQuery += "   parse1:"+CRLF
	cQuery += "   WHILE (vITAMSTR  >= vINX ) DO"+CRLF
	cQuery += "    set vCREF  = SUBSTR ( IN_SOMAR  || '#' , vITAMSTR , 1 );"+CRLF
	cQuery += "    IF vCREF  = ' '  THEN "+CRLF
	cQuery += "     set vCRESULT  = ' '  || vCRESULT ;"+CRLF
	cQuery += "     set vCNEXT  = '1' ;"+CRLF
	cQuery += "     set vCSPACE  = '1' ;"+CRLF
	cQuery += "    ELSE "+CRLF
	cQuery += "     IF IN_SOMAR  =  REPEAT( 'z' , vITAMORI)  THEN "+CRLF
	cQuery += "      set vCRESULT  = REPEAT( '*' , vITAMORI) ;"+CRLF
	cQuery += "      leave parse1;"+CRLF
	cQuery += "     ELSE "+CRLF
	cQuery += "      IF vCREF  < '9'  THEN "+CRLF
	cQuery += "       set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || SUBSTR ( vSTRBASE , LOCATE( vCREF , vSTRBASE ) + 1 , 1 )  || vCRESULT ;"+CRLF
	cQuery += "       set vCNEXT  = '0' ;"+CRLF
	cQuery += "      ELSE "+CRLF
	cQuery += "       IF  (vCREF  = '9'  AND vITAMSTR  > 1 )  THEN "+CRLF
	cQuery += "        IF  (SUBSTR ( IN_SOMAR , vITAMSTR  - 1 , 1 ) <= '9'  AND SUBSTR ( IN_SOMAR , vITAMSTR  - 1 , 1 ) <> ' ' )  THEN "+CRLF
	cQuery += "         set vCRESULT  = '0'  || vCRESULT ;"+CRLF
	cQuery += "         set vCNEXT  = '1' ;"+CRLF
	cQuery += "        ELSE "+CRLF
	cQuery += "         IF  (SUBSTR ( IN_SOMAR ,  ( vITAMSTR ) , 1 ) = ' ' )  THEN "+CRLF
	cQuery += "          set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 2 ) ) || '10'  || vCRESULT ;"+CRLF
	cQuery += "          set vCNEXT  = '0' ;"+CRLF
	cQuery += "         ELSE "+CRLF
	cQuery += "          set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || 'A'  || vCRESULT ;"+CRLF
	cQuery += "          set vCNEXT  = '0' ;"+CRLF
	cQuery += "         END IF;"+CRLF
	cQuery += "        END IF;"+CRLF
	cQuery += "       ELSE "+CRLF
	cQuery += "        IF vCREF  = '9'  AND  (vITAMSTR  = 1 )  AND  (vCSPACE  = '1' )  THEN "+CRLF
	cQuery += "         set vCRESULT  = '10'  || SUBSTR ( vCRESULT , 1 ,  (LENGTH ( vCRESULT  || '#' ) - 1 ) );"+CRLF
	cQuery += "         set vCNEXT  = '0' ;"+CRLF
	cQuery += "        ELSE "+CRLF
	cQuery += "         IF vCREF  = '9'  AND vITAMSTR  = 1  AND vCSPACE  = '0'  THEN "+CRLF
	cQuery += "          set vCRESULT  = 'A'  || vCRESULT ;"+CRLF
	cQuery += "          set vCNEXT  = '0' ;"+CRLF
	cQuery += "         ELSE "+CRLF
	cQuery += "          IF vCREF  > '9'  AND vCREF  < 'Z'  THEN "+CRLF
	cQuery += "           set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || SUBSTR ( vSTRBASE , LOCATE( vCREF , vSTRBASE ) + 1 , 1 )  || vCRESULT ;"+CRLF
	cQuery += "           set vCNEXT  = '0' ;"+CRLF
	cQuery += "          ELSE "+CRLF
	cQuery += "           IF vCREF  > 'Z'  AND vCREF  < 'z'  THEN "+CRLF
	cQuery += "            set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || SUBSTR ( vSTRBASE , LOCATE( vCREF , vSTRBASE ) + 1 , 1 )  || vCRESULT ;"+CRLF
	cQuery += "            set vCNEXT  = '0' ;"+CRLF
	cQuery += "           ELSE "+CRLF
	cQuery += "            IF vCREF  = 'Z'  AND IN_SOMALOW  = '1'  THEN "+CRLF
	cQuery += "             set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || 'a'  || vCRESULT ;"+CRLF
	cQuery += "             set vCNEXT  = '0' ;"+CRLF
	cQuery += "            ELSE "+CRLF
	cQuery += "             IF  (vCREF  = 'z'  OR vCREF  = 'Z' )  AND vCSPACE  = '1'  THEN "+CRLF
	cQuery += "              set vCRESULT  = SUBSTR ( IN_SOMAR , 1 , vITAMSTR ) || '0'  || SUBSTR ( vCRESULT , 1 ,  (LENGTH ( vCRESULT  || '#' "+CRLF
	cQuery += "                     ) - 2 ) );"+CRLF
	cQuery += "              set vCNEXT  = '0' ;"+CRLF
	cQuery += "             ELSE "+CRLF
	cQuery += "              IF vCREF  = 'z'  OR vCREF  = 'Z'  THEN "+CRLF
	cQuery += "               set vCRESULT  = '0'  || vCRESULT ;"+CRLF
	cQuery += "               set vCNEXT  = '1' ;"+CRLF
	cQuery += "              END IF;"+CRLF
	cQuery += "             END IF;"+CRLF
	cQuery += "            END IF;"+CRLF
	cQuery += "           END IF;"+CRLF
	cQuery += "          END IF;"+CRLF
	cQuery += "         END IF;"+CRLF
	cQuery += "        END IF;"+CRLF
	cQuery += "       END IF;"+CRLF
	cQuery += "      END IF;"+CRLF
	cQuery += "     END IF;"+CRLF
	cQuery += "    END IF;"+CRLF
	cQuery += "    IF vCNEXT  = '0'  THEN "+CRLF
	cQuery += "     leave parse1;"+CRLF
	cQuery += "    END IF;"+CRLF
	cQuery += "    set vITAMSTR  = vITAMSTR  - 1 ;"+CRLF
	cQuery += "   END WHILE;"+CRLF
	cQuery += "   set OUT_RESULTADO  = vCRESULT ;"+CRLF
	cQuery += "  END IF;"+CRLF
	cQuery += " END IF;"+CRLF
	cQuery += "END"+CRLF
ElseIf Upper(Trim(TcGetDb())) = "INFORMIX"
	cQuery := "CREATE PROCEDURE "+cSoma1+"_"+cEmpAnt+" ("+CRLF

	cQuery += "IN_SOMAR VARCHAR( 100 ) ,"+CRLF
	cQuery += "IN_SOMALOW CHAR( 01 ) )"+CRLF

	cQuery += "Returning  VARCHAR( 100 );"+CRLF

	cQuery += "DEFINE OUT_RESULTADO VARCHAR( 100 ) ;"+CRLF
	cQuery += "DEFINE vIAUX INTEGER ;"+CRLF
	cQuery += "DEFINE vITAMORI INTEGER ;"+CRLF
	cQuery += "DEFINE vINX INTEGER ;"+CRLF
	cQuery += "DEFINE vCNEXT CHAR( 01 ) ;"+CRLF
	cQuery += "DEFINE vCSPACE CHAR( 01 ) ;"+CRLF
	cQuery += "DEFINE vCREF VARCHAR( 1 ) ;"+CRLF
	cQuery += "DEFINE vCRESULT VARCHAR( 100 ) ;"+CRLF
	cQuery += "DEFINE vITAMSTR INTEGER ;"+CRLF
	cQuery += "DEFINE vCALFAUPPER VARCHAR( 200 ) ;"+CRLF
	cQuery += "DEFINE vCALFALOWER VARCHAR( 200 ) ;"+CRLF
	cQuery += "DEFINE vCASCII VARCHAR(02);"+CRLF
	cQuery += "DEFINE vIPOS INTEGER;"+CRLF
	
	cQuery += "BEGIN"+CRLF
	
	cQuery += "	LET vCALFAUPPER = '65A66B67C68D69E70F71G72H73I74J75K76L77M78N79O80P81Q82R83S84T85U86V87W88X89Y90Z';"+CRLF
	cQuery += "   LET vITAMSTR  =  (LENGTH ( IN_SOMAR  || '#' ) - 1 ) ;"+CRLF
	cQuery += "   LET vITAMORI  =  (LENGTH ( IN_SOMAR  || '#' ) - 1 ) ;"+CRLF
	cQuery += "   LET vIAUX  = 1 ;"+CRLF
	cQuery += "   LET vINX  = 1 ;"+CRLF
	cQuery += "   LET vCREF  = ' ' ;"+CRLF
	cQuery += "   LET vCNEXT  = '0' ;"+CRLF
	cQuery += "   LET vCSPACE  = '0' ;"+CRLF
	cQuery += "   LET vCRESULT  = ' ' ;"+CRLF
	cQuery += "	LET OUT_RESULTADO = '';"+CRLF
	cQuery += "	LET vCASCII = ' ';"+CRLF
	cQuery += "	LET vIPOS = 1;"+CRLF
		
	cQuery += "   IF LENGTH ( RTRIM ( IN_SOMAR )) = 0  THEN"+CRLF
	cQuery += "      CALL MSSTRZERO_24_T1 (vIAUX , vITAMSTR ) RETURNING OUT_RESULTADO ;"+CRLF
	cQuery += "   ELSE"+CRLF
	cQuery += "      IF IN_SOMAR  = RPAD('*',vITAMORI,'*') THEN"+CRLF
	cQuery += "         LET OUT_RESULTADO  = IN_SOMAR ;"+CRLF
	cQuery += "      ELSE"+CRLF
	cQuery += "         WHILE (vITAMSTR  >= vINX )"+CRLF
	cQuery += "            LET vCREF  = SUBSTR ( IN_SOMAR  || '#' , vITAMSTR , 1 );"+CRLF				
	cQuery += "            IF vCREF  = ' '  THEN"+CRLF
	cQuery += "               LET vCRESULT  = ' '  || vCRESULT ;"+CRLF
	cQuery += "               LET vCNEXT  = '1' ;"+CRLF
	cQuery += "               LET vCSPACE  = '1' ;"+CRLF
	cQuery += "            ELSE"+CRLF
	cQuery += "               IF IN_SOMAR  =  RPAD('Z',vITAMORI,'Z') THEN"+CRLF
	cQuery += "                  LET vCRESULT  =  RPAD('*',vITAMORI,'*') ;"+CRLF
	cQuery += "                  EXIT WHILE;"+CRLF
	cQuery += "               ELSE"+CRLF
	cQuery += "                  IF vCREF  < '9'  THEN"+CRLF
	cQuery += "                     LET vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || SUBSTR(TO_CHAR (((TO_NUMBER(  vCREF ) + 1)) ),1,  1)||vCRESULT;"+CRLF
	cQuery += "                     LET vCNEXT  = '0' ;"+CRLF
	cQuery += "                  ELSE"+CRLF
	cQuery += "                     IF  (vCREF  = '9'  and vITAMSTR  > 1 )  THEN"+CRLF
	cQuery += "                        IF  (SUBSTR ( IN_SOMAR , vITAMSTR  - 1 , 1 ) <= '9'  and SUBSTR ( IN_SOMAR , vITAMSTR  - 1 , 1 ) <> ' '      )  THEN"+CRLF
	cQuery += "                           LET vCRESULT  = '0'  || vCRESULT ;"+CRLF
	cQuery += "                           LET vCNEXT  = '1' ;"+CRLF
	cQuery += "                        ELSE"+CRLF
	cQuery += "                           IF  (SUBSTR ( IN_SOMAR ,  ( vITAMSTR ) , 1 ) = ' ' )  THEN"+CRLF
	cQuery += "                              LET vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 2 ) ) || '10'  || vCRESULT ;"+CRLF
	cQuery += "                              LET vCNEXT  = '0' ;"+CRLF
	cQuery += "                           ELSE"+CRLF
	cQuery += "                              LET vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || 'A'  || vCRESULT ;"+CRLF
	cQuery += "                              LET vCNEXT  = '0' ;"+CRLF
	cQuery += "                           END IF;"+CRLF
	cQuery += "                        END IF;"+CRLF
	cQuery += "                     ELSE"+CRLF
	cQuery += "                        IF vCREF  = '9'  and  (vITAMSTR  = 1 )  and  (vCSPACE  = '1' )  THEN"+CRLF
	cQuery += "                           LET vCRESULT  = '10'  || SUBSTR ( vCRESULT , 1 ,  (LENGTH ( vCRESULT  || '#' ) - 1 ) );"+CRLF
	cQuery += "                           LET vCNEXT  = '0' ;"+CRLF
	cQuery += "                        ELSE"+CRLF
	cQuery += "                           IF vCREF  = '9'  and vITAMSTR  = 1  and vCSPACE  = '0'  THEN"+CRLF
	cQuery += "                              LET vCRESULT  = 'A'  || vCRESULT ;"+CRLF
	cQuery += "                              LET vCNEXT  = '0' ;"+CRLF
	cQuery += "                           ELSE"+CRLF
	cQuery += "                              IF vCREF  > '9'  and vCREF  < 'Z'  THEN"+CRLF
	cQuery += "											LET vCASCII = TO_CHAR(ASCII ( vCREF ) + 1);"+CRLF
	cQuery += "											LET vIPOS = 1;"+CRLF
	cQuery += "											While vIPOS <= LENGTH(vCALFAUPPER)"+CRLF
	cQuery += "												If SUBSTR(vCALFAUPPER, vIPOS , 2) = vCASCII THEN"+CRLF
	cQuery += "													LET vCASCII = SUBSTR(vCALFAUPPER, vIPOS + 2 , 1);"+CRLF
	cQuery += "													EXIT WHILE;"+CRLF
	cQuery += "												END IF;"+CRLF
	cQuery += "												LET vIPOS = vIPOS + 3   ;"+CRLF
	cQuery += "											End While;"+CRLF
	cQuery += "                                 LET vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || vCASCII|| vCRESULT ;"+CRLF
	cQuery += "                                 LET vCNEXT  = '0' ;"+CRLF
	cQuery += "                              ELSE"+CRLF
	cQuery += "                                 IF vCREF  > 'Z'  and vCREF  < 'z'  THEN"+CRLF
	cQuery += "												IF vCREF = 'a' THEN"+CRLF
	cQuery += "													LET vCASCII = 'b';"+CRLF
	cQuery += "												ELIF vCREF = 'b' THEN"+CRLF
	cQuery += "													LET vCASCII = 'c';"+CRLF
	cQuery += "												END IF;"+CRLF
	cQuery += "												LET vIPOS = 1;"+CRLF
	cQuery += "												While vIPOS <= LENGTH(vCALFALOWER)"+CRLF
	cQuery += "													LET vCASCII = TO_CHAR(ASCII ( vCREF ) + 1);"+CRLF
	cQuery += "													If SUBSTR(vCALFAUPPER, vIPOS , 3) = vCASCII THEN"+CRLF
	cQuery += "														LET vCASCII = SUBSTR(vCALFALOWER, vIPOS + 3 , 1);"+CRLF
	cQuery += "														EXIT WHILE;"+CRLF
	cQuery += "													END IF;"+CRLF
	cQuery += "													LET vIPOS = vIPOS + 4   ;"+CRLF
	cQuery += "												End While;"+CRLF
	cQuery += "                                    LET vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || vCASCII || vCRESULT ;"+CRLF
	cQuery += "                                    LET vCNEXT  = '0' ;"+CRLF
	cQuery += "                                 ELSE"+CRLF
	cQuery += "                                    IF vCREF  = 'Z'  and IN_SOMALOW  = '1'  THEN"+CRLF
	cQuery += "                                       LET vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || 'a'  || vCRESULT ;"+CRLF
	cQuery += "                                       LET vCNEXT  = '0' ;"+CRLF
	cQuery += ""+CRLF
	cQuery += "                                    ELSE"+CRLF
	cQuery += ""+CRLF
	cQuery += "                                       IF  (vCREF  = 'Z'  or vCREF  = 'Z' )  and vCSPACE  = '1'  THEN"+CRLF
	cQuery += "                                          LET vCRESULT  = SUBSTR ( IN_SOMAR , 1 , vITAMSTR ) || '0'  || SUBSTR ( vCRESULT , 1 ,  (LENGTH ( vCRESULT  || '#') - 2 ) );"+CRLF
	cQuery += "                                          LET vCNEXT  = '0' ;"+CRLF
	cQuery += "                                       ELSE"+CRLF
	cQuery += "                                          IF vCREF  = 'Z'  or vCREF  = 'Z'  THEN"+CRLF
	cQuery += "                                                LET vCRESULT  = '0'  || vCRESULT ;"+CRLF
	cQuery += "                                                LET vCNEXT  = '1' ;"+CRLF
	cQuery += "                                          END IF;"+CRLF
	cQuery += "                                       END IF;"+CRLF
	cQuery += "                                    END IF;"+CRLF
	cQuery += "                                 END IF;"+CRLF
	cQuery += "                              END IF;"+CRLF
	cQuery += "                           END IF;"+CRLF
	cQuery += "                        END IF;"+CRLF
	cQuery += "                     END IF;"+CRLF
	cQuery += "                  END IF;"+CRLF
	cQuery += "               END IF;"+CRLF
	cQuery += "            END IF;"+CRLF
	cQuery += "            IF vCNEXT  = '0'  THEN"+CRLF
	cQuery += "               EXIT WHILE;"+CRLF
	cQuery += "            END IF;"+CRLF
	cQuery += "            LET vITAMSTR  = vITAMSTR  - 1 ;"+CRLF
	cQuery += "         END WHILE"+CRLF
	cQuery += "         LET OUT_RESULTADO  = vCRESULT ;"+CRLF
	cQuery += "      END IF;"+CRLF
	cQuery += "   END IF;"+CRLF
	cQuery += "   Return  OUT_RESULTADO;"+CRLF
	cQuery += "END"+CRLF
	cQuery += "END PROCEDURE;"+CRLF
ElseIf Alltrim(Upper(TcGetDb()))=="POSTGRES"
	
	cQuery := " "+CRLF
	cQuery += "---------------------------------------------------------------------------- "+CRLF
	cQuery += "--    Procedure   -  Soma 1 em uma sequencia caractere qualquer "+CRLF
	cQuery += "--    Entrada     -  IN_SOMAR       - String a qual será somado 1 "+CRLF
	cQuery += "--                   IN_SOMALOW     - Considera letras minúsculas () "+CRLF
	cQuery += "--                   OUT_RESULTADO  - String acrescida em 1 "+CRLF
	cQuery += "--    Responsavel :  Totvs by Emerson Rony de Oliveira "+CRLF
	cQuery += "--    Data        :  30/11/2016 "+CRLF
	cQuery += "---------------------------------------------------------------------------- "+CRLF 
	cQuery += "CREATE OR REPLACE FUNCTION "+cSoma1+"_"+cEmpAnt+" "+CRLF
	cQuery += "( "+CRLF
	cQuery += " IN_SOMAR VARCHAR( 100 ) , "+CRLF 
	cQuery += " IN_SOMALOW CHAR( 01 ) ,  "+CRLF
	cQuery += " OUT OUT_RESULTADO VARCHAR( 254 ) "+CRLF 
	cQuery += ") AS $$ "+CRLF
	cQuery += " "+CRLF
	cQuery += "DECLARE "+CRLF
	cQuery += "  vIAUX INTEGER ; "+CRLF
	cQuery += "  vITAMORI INTEGER ; "+CRLF
	cQuery += "  vINX INTEGER ; "+CRLF
	cQuery += "  vCNEXT CHAR( 01 ) ; "+CRLF
	cQuery += "  vCSPACE CHAR( 01 ) ; "+CRLF
	cQuery += "  vCREF VARCHAR( 1 ) ; "+CRLF
	cQuery += "  vCRESULT VARCHAR( 100 ) ; "+CRLF
	cQuery += "  vITAMSTR INTEGER ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "BEGIN "+CRLF
	cQuery += " "+CRLF
	cQuery += "vITAMSTR  :=  (LENGTH ( CONCAT ( IN_SOMAR, '#' ) ) - 1 ) ; "+CRLF
	cQuery += "vITAMORI  :=  (LENGTH ( CONCAT ( IN_SOMAR, '#' ) ) - 1 ) ; "+CRLF
	cQuery += "vIAUX     := 1 ; "+CRLF
	cQuery += "vINX      := 1 ; "+CRLF
	cQuery += "vCREF     := ' ' ; "+CRLF
	cQuery += "vCNEXT    := '0' ; "+CRLF
	cQuery += "vCSPACE   := '0' ; "+CRLF
	cQuery += "vCRESULT  := ' ' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "IF LENGTH ( RTRIM ( IN_SOMAR )) = 0  THEN "+CRLF 
	cQuery += " "+CRLF   
	cQuery += "   SELECT MSSTRZERO (vIAUX , vITAMSTR , OUT_RESULTADO ); "+CRLF
	cQuery += " "+CRLF
	cQuery += "ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "   IF IN_SOMAR = REPEAT( '*' , vITAMORI) THEN "+CRLF 
	cQuery += " "+CRLF      
	cQuery += "      OUT_RESULTADO := IN_SOMAR ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "   ELSE "+CRLF 
	cQuery += " "+CRLF   
	cQuery += "      WHILE (vITAMSTR  >= vINX ) LOOP "+CRLF
	cQuery += " "+CRLF         
	cQuery += "         vCREF := SUBSTR ( CONCAT ( IN_SOMAR, '#'), vITAMSTR , 1 ); "+CRLF
	cQuery += " "+CRLF
	cQuery += "         IF vCREF = ' '  THEN "+CRLF 
	cQuery += " "+CRLF            
	cQuery += "            vCRESULT := CONCAT ( ' ', vCRESULT ) ; "+CRLF
	cQuery += "            vCNEXT   := '1' ; "+CRLF
	cQuery += "            vCSPACE  := '1' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "         ELSE "+CRLF
	cQuery += " "+CRLF     
	cQuery += "            IF IN_SOMAR  =  REPEAT( 'Z' , vITAMORI)  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "               vCRESULT := REPEAT( '*' , vITAMORI) ; "+CRLF
	cQuery += "               Exit; "+CRLF
	cQuery += " "+CRLF
	cQuery += "            ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "               IF vCREF  < '9'  THEN "+CRLF 
	cQuery += " "+CRLF        
	cQuery += "                  vCRESULT := CONCAT ( SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ), CHR ( ASCII ( vCREF ) + 1 ), vCRESULT ) ; "+CRLF
	cQuery += "                  vCNEXT := '0' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "               ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                  IF  (vCREF  = '9'  AND vITAMSTR  > 1 )  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                     IF  (SUBSTR ( IN_SOMAR , vITAMSTR  - 1 , 1 ) <= '9'  AND SUBSTR ( IN_SOMAR , vITAMSTR  - 1 , 1 ) <> ' ' )  THEN "+CRLF 
	cQuery += " "+CRLF                        
	cQuery += "                        vCRESULT := CONCAT ( '0', vCRESULT ) ; "+CRLF
	cQuery += "                        vCNEXT  := '1' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                     ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                        IF  (SUBSTR ( IN_SOMAR ,  ( vITAMSTR ) , 1 ) = ' ' )  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                           vCRESULT := CONCAT ( SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 2 ) ), '10', vCRESULT ) ; "+CRLF
	cQuery += "                           vCNEXT := '0' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                        ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                           vCRESULT := CONCAT ( SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ), 'A', vCRESULT ) ; "+CRLF
	cQuery += "                           vCNEXT := '0' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                        END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                     END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                  ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                     IF vCREF  = '9'  AND  (vITAMSTR  = 1 )  AND  (vCSPACE  = '1' )  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                        vCRESULT := CONCAT ( '10', SUBSTR ( vCRESULT , 1 ,  (LENGTH ( CONCAT ( vCRESULT, '#' ) ) - 1 ) ) ) ; "+CRLF
	cQuery += "                        vCNEXT := '0' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                     ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                        IF vCREF  = '9'  AND vITAMSTR  = 1  AND vCSPACE  = '0'  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                           vCRESULT := CONCAT ( 'A', vCRESULT ) ; "+CRLF
	cQuery += "                           vCNEXT := '0' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                        ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                           IF vCREF  > '9'  AND vCREF  < 'Z'  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                              vCRESULT := CONCAT ( SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ), CHR ( (ASCII ( vCREF ) + 1 ) ), vCRESULT ) ; "+CRLF
	cQuery += "                              vCNEXT := '0' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                           ELSE "+CRLF
	cQuery += " "+CRLF
	cQuery += "                              IF vCREF  > 'Z'  AND vCREF  < 'Z'  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                                 vCRESULT := CONCAT ( SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ), CHR (  (ASCII ( vCREF ) + 1 ) ), vCRESULT ) ; "+CRLF
	cQuery += "                                 vCNEXT := '0' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                              ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                                 IF vCREF  = 'Z'  AND IN_SOMALOW  = '1'  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                                    vCRESULT := CONCAT ( SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ), 'A', vCRESULT ) ; "+CRLF
	cQuery += "                                    vCNEXT := '0' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                                 ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                                    IF  (vCREF  = 'Z'  OR vCREF  = 'Z' )  AND vCSPACE  = '1'  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                                       vCRESULT := CONCAT ( SUBSTR ( IN_SOMAR , 1 , vITAMSTR ), '0', SUBSTR ( vCRESULT , 1 ,  (LENGTH ( CONCAT ( vCRESULT, '#' ) ) - 2 ) ) ) ; "+CRLF
	cQuery += "                                       vCNEXT := '0' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                                    ELSE "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                                       IF vCREF  = 'Z'  OR vCREF  = 'Z'  THEN "+CRLF 
	cQuery += " "+CRLF
	cQuery += "                                          vCRESULT := CONCAT ( '0', vCRESULT ) ; "+CRLF
	cQuery += "                                          vCNEXT := '1' ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                                       END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                                    END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                                 END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                              END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                           END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                        END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                     END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "                  END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "               END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "            END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "         END IF; "+CRLF
	cQuery += " "+CRLF    
	cQuery += "         IF vCNEXT  = '0'  THEN "+CRLF 
	cQuery += "            Exit; "+CRLF
	cQuery += "         END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "         vITAMSTR := vITAMSTR  - 1 ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "      END LOOP; "+CRLF
	cQuery += " "+CRLF
	cQuery += "      OUT_RESULTADO := vCRESULT ; "+CRLF
	cQuery += " "+CRLF
	cQuery += "   END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "END IF; "+CRLF
	cQuery += " "+CRLF
	cQuery += "END $$ LANGUAGE 'plpgsql' "+CRLF
	
EndIf
xProc := ''
For nCnt01 := 1 to Len(cQuery)
    nCaracter := asc(Substr(cQuery,nCnt01,1))
    if nCaracter == 13
       xProc += ''
    elseif nCaracter == 10
       xProc +=chr(10)
    else 
       xProc += Subs(cQuery,nCnt01,1)
    endif
Next
cQuery:=xProc

RestArea(aSaveArea)
Return(cQuery)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³pVldDb2400  ³ Autor ³ siga                  ³ Data ³02.07.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza ajustes na procedure para aplicar no DB2 do AS400    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³pVldDb2400( cBuffer )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cBuffer- procedure a ser ajustada para o db2/400    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function pVldDb2400( cBuffer )
Local lTop4AS400   := ('ISERIES'$Upper(TcSrvType()))
Local lTop4ASASCII := .F.
Local cTOP400Alias := ""
Local nPos3        := 0 

// Sendo tool ou nao, ajusta sintaxe para AS400 com TOP4
If lTop4AS400

	// Identifica se o TOP4 AS400 é o build novo, com tratamento ASCII
	If val(TCInternal(80)) >= 20081008
		lTop4ASASCII := .T.
	Endif
	
	// Identifica nome do Schema ( Alias )
	cTOP400Alias := GetSrvProfString('DBALIAS','')
	If empty(cTOP400Alias)
		cTOP400Alias := GetSrvProfString('TOPALIAS','')
	Endif
	If empty(cTOP400Alias)
		cTOP400Alias := GetPvProfString('TOTVSDBACCESS','ALIAS','',GetAdv97())
	Endif
	If empty(cTOP400Alias)
		cTOP400Alias := GetPvProfString('TOPCONNECT','ALIAS','',GetAdv97())
	Endif
	
	// Troca operadores de concatenacao e diferenca
	cBuffer	:= StrTran( cBuffer, '||', ' CONCAT ' )
	cBuffer	:= StrTran( cBuffer, '!=', '<>' )
	
	// Se for criação de FUNCTION, deve ser especificado
	// LANGUAGE SQL NOT FENCED antes do BEGIN
	
	If !"LANGUAGE SQL"$upper(cBuffer)
		nPos3 := at("BEGIN",upper(cBuffer))
		if nPos3 > 0
			cBuffer	:= Stuff(cBuffer,nPos3,0,"LANGUAGE SQL NOT FENCED"+CRLF)
		Endif
	Endif
	
	// Localiza o begin novamente, e acrescenta o sort sequence 
	// diferenciado para  o TOP4 AS400 
	// Mas apenas coloca isso se for build antigo, antes do ASCII

	If !lTop4ASASCII
		nPos3 := at("BEGIN",upper(cBuffer))
		If nPos3 > 0
			cBuffer	:= Stuff(cBuffer,nPos3,0,"SET OPTION SRTSEQ = TOP40/TOPASCII"+CRLF)
		Endif
	Endif

	// Prefixa as chamadas de stored procedures com o nome do banco/alias atual
	cBuffer := UPstrtran(cBuffer,"CALL ","CALL "+cTOP400Alias+".")
	
	// Prefixa as chamadas de functions com o alias do banco (schema) atual
	aeval(a400Funcs , {|x| cBuffer := UPstrtran(cBuffer,x,cTOP400Alias+"."+x) } )

	// Utilizado para passar qualquer erro nao tratado para o nivel superior  
	// Declara handler de erro para fazer RESIGNAL de qualquer SQL Exception
	// se j'a tem um handler declarado, faz ap'os ele. 
	// Se nao tem, faz apos ultimo declare encontrado.
	nPos3 := at("DECLARE CONTINUE HANDLER",upper(cBuffer))
	If nPos3 > 0
		cBuffer	:= Stuff(cBuffer,nPos3,0,"DECLARE EXIT HANDLER FOR SQLEXCEPTION "+CRLF+"   RESIGNAL ;"+CRLF)
	Else
		nPos3 := rat("DECLARE ",upper(cBuffer))
		If nPos3 > 0
			while substr(cBuffer,nPos3,1) != chr(10)
				nPos3++
			Enddo
			nPos3++
			cBuffer	:= Stuff(cBuffer,nPos3,0,"DECLARE EXIT HANDLER FOR SQLEXCEPTION "+CRLF+"   RESIGNAL ;"+CRLF)
		Endif
	Endif

	// Coloca commitment level *CHG !! Sem ele, a procedure ocasiona erro caso tente fazer um rollback em caso de erro interno...
	nPos3 := at("BEGIN",upper(cBuffer))
	If nPos3 > 0
		cBuffer	:= Stuff(cBuffer,nPos3,0,"SET OPTION COMMIT = *CHG"+CRLF)
	Endif

	// DEBUG - Mostra corpo da procedure gerado no console
	/*
	conout(replicate('=',79 ))
	conout(cBuffer)
	conout(replicate('=',79 ))
	*/

Endif
Return(cBuffer)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Somente para o INFORMIX                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
*/
Function cCriaSPIFX()
Local lRet   := .t.
Local cQuery := ""
Local n
Local nRet := 0

cQuery+=CRLF
cQuery+="CREATE PROCEDURE TX() RETURNING INTEGER;"+CRLF
cQuery+="  DEFINE in_tx INTEGER;"+CRLF
cQuery+="  BEGIN"+CRLF
cQuery+="	ON EXCEPTION IN (-535) ROLLBACK WORK;"+CRLF
cQuery+="	  RETURN 1; -- Already in transaction"+CRLF
cQuery+="	END EXCEPTION; "+CRLF
cQuery+="	BEGIN WORK;"+CRLF
cQuery+="	-- If it fails it's because you're yet in transaction"+CRLF
cQuery+="	COMMIT WORK;"+CRLF
cQuery+="	RETURN 1;"+CRLF
cQuery+="  END"+CRLF
cQuery+="END PROCEDURE;"+CRLF
cQuery+=CRLF

If !TCSPExist("TX")
	nRet := TcSqlExec( cQuery )
	If nRet <> 0
		If !lBlind
			MsgAlert( 'Erro na criacao da procedure' + " " + TcSQLError() )  //'Erro na criacao da procedure'
		EndIf
		lret := .F.
	EndIf
EndIf

Return(lRet)
