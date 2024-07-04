#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ SE5811   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 23.07.03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Normaliza SE5, gravando norme do cliente ou fornecedor, em  ³±±
±±³          ³ seus respectivos campos, E5_CLIENTE e E5_FORNECE a partir do|±±
±±³          ³ campo E5_CLIFOR                                             |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SE5811()
Local aSaveArea	:= GetArea()
Local cFiltro
Local cAlias
Local cFile		:= "SE5"+cEmpAnt+"UPD.log"
Local nHdlFile	:= 0
Local cFilialSE1, cFilialSE2 := ''
Local lLimpar		:= .F.
Local lContinua	:= .T.

#IFDEF TOP
	Local aStru
	Local cProc    := ""
	Local cQuery   := ""	
	Local nRet     := 0
	Local aResult  := {'0'}
	Local lRet     := .T.
	Local cMV_PAGANT := MVPAGANT
	Local cMV_CPNEG  := MV_CPNEG
	Local cMV_RECANT := MVRECANT
	Local cMV_CRNEG  := MV_CRNEG
#ENDIF

//-------------------------------------------------------
// Tratamento para executar somente se a versao base é 7
//-------------------------------------------------------
If _UPD811 .Or. _UPD101
	lContinua := .F.	
EndIf

If lContinua

	CriaTipos()
	DbSelectArea("SE5")   
	DbSetOrder(1)
	If Empty(xFilial("SE5")) .and. File(cFile)
		Return .T.				/// SE O ARQUIVO É COMPARTILHADO E O ARQUIVO LOG JA EXISTE (JA RODOU) CANCELA.
	Endif
	#IFDEF TOP
		If TcSrvType() != "AS/400"
			lRet := Filial()
			If lRet
				cProc := SE5811Proc()
				If ExistProc( "SE5811" )
					nRet := TcSqlExec("DROP PROCEDURE SE5811_"+cEmpAnt)
					If nRet <> 0
						lRet := .F.                                           	
					EndIf
				EndIf
	      	nRet := TcSqlExec(cProc)
				If nRet < 0
					lRet := .F.
				else
					MsgRun("Atualizando","Compatibilizacao SE1/SE2/SE5", {||aResult := TCSPEXEC( xProcedures("SE5811"), xFilial("SE5"), cMV_PAGANT, cMV_CPNEG,;
																											 	cMV_RECANT, cMV_CRNEG )})
					if aResult == nil
				   	aResult := {'0'}
					endif				
					nRet := TcSqlExec("DROP PROCEDURE SE5811_"+cEmpAnt)
	  			EndIf
	  		EndIf
		Endif
		If TcSrvType() = "AS/400" .or. (!lRet) .Or. aResult[1] != '1'
	#ENDIF

	#IFDEF TOP
		aStru := SE5->(DbStruct())
		cFiltro := "SELECT R_E_C_N_O_ RECNO "
		cFiltro += "  FROM "+	RetSqlName("SE5")
		cFiltro += " WHERE E5_FILIAL = '"+xFilial("SE5")+"'"
		cFiltro += " AND E5_CLIFOR <> '"+ Space(Len(E5_CLIFOR))+"'" 
		cFiltro += " AND E5_NUMERO <> '"+ Space(Len(E5_NUMERO))+"'" 
		cFiltro += " AND D_E_L_E_T_ <> '*' "
		cFiltro := ChangeQuery(cFiltro)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "TRBSE5", .F., .T.)
		aEval(aStru, {|e| If(e[2] != "C", TCSetField("TRBSE5", e[1], e[2],e[3],e[4]),Nil)})
		cAlias := "TRBSE5"
	#ELSE
		cIndex	:= CriaTrab(nil,.f.)
		cFiltro  := 'E5_FILIAL=="'+xFilial("SE5")+'".And.'	
		cFiltro	+= "E5_CLIFOR <> '" + Space(Len(E5_CLIFOR))+"'.And."
		cFiltro	+= "E5_NUMERO <> '" + Space(Len(E5_NUMERO))+"'"
		IndRegua("SE5",cIndex,IndexKey(1),,cFiltro,"Selecionando Registros...")
		nIndex	:= RetIndex("SE5")
		dbSetIndex(cIndex+OrdBagExt())
		dbSetOrder(nIndex+1)
		cAlias := "SE5"
	#ENDIF	
	DbGoTop()
	UpdSet01(LastRec())
	While (cAlias)->(!Eof())
		UpdInc01("Updating SE5",.T.)
		#IFDEF TOP
			//Posiciono no SE5
			SE5->(DBGOTO((cAlias)->RECNO))
		#ENDIF
   	//Gravar campos E5_CLIENTE e E5_FORNECE
		If Reclock("SE5",.F.)
			Do Case
			Case E5_TIPO $ MVPAGANT + "/" + MV_CPNEG
				REPLACE E5_FORNECE With E5_CLIFOR	
			Case E5_TIPO $ MVRECANT + "/" + MV_CRNEG
				REPLACE E5_CLIENTE With E5_CLIFOR	
			Case E5_RECPAG = "R" .And. E5_TIPODOC = "ES"
				REPLACE E5_FORNECE With E5_CLIFOR	
			Case E5_RECPAG = "P" .And. E5_TIPODOC = "ES"
				REPLACE E5_CLIENTE With E5_CLIFOR	
			// Movimento a Pagar
			Case E5_RECPAG = "P"	
				REPLACE E5_FORNECE With E5_CLIFOR
			// Movimento a receber	
			Case E5_RECPAG = "R"
				REPLACE E5_CLIENTE With E5_CLIFOR
			EndCase
			MsUnLock()
			If !Empty(E5_CLIENTE)
				dbSelectArea("SE1")
				dbSetorder(1)

				//>>> Corrige a integridade com o E1. 
				cFilialSE1 := xFilial("SE1")
				lLimpar := !dbSeek(cFilialSE1 + SE5->(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO))
				//Se nao encontrou tenta pesquisar pela filial origem se houver e se for diferente da atual.
				If lLimpar .and. SE5->(FieldPos("E5_FILORIG")) > 0
					If !Empty(SE5->E5_FILORIG) .and. !(Empty(cFilialSE1)) .and. (cFilialSE1 <> SE5->E5_FILORIG)
						cFilialSE1 := SE5->E5_FILORIG
						lLimpar := !dbSeek(cFilialSE1+SE5->(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO))
					Endif
				Endif	
				if lLimpar
					//Limpar a chave do relacionamento.
					RecLock("SE5",.F.)
					REPLACE E5_KEY 		With E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO
					REPLACE E5_PREFIXO 	With ""
					REPLACE E5_NUMERO		With ""
					REPLACE E5_PARCELA 	With ""
					REPLACE E5_TIPO		With ""
					MsUnLock()				
				Endif
				//<<< Corrige a integridade com o E1. 
			
			ElseIf !Empty(E5_FORNECE)
				dbSelectArea("SE2")
				dbSetorder(1)

				//>>> Corrige a integridade com o E2. 
				cFilialSE2 := xFilial("SE2")
				lLimpar := !dbSeek(cFilialSE2 + SE5->(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO))
				//Se nao encontrou tenta pesquisar pela filial origem se houver e se for diferente da atual.
				If lLimpar .and. SE5->(FieldPos("E5_FILORIG")) > 0
					If !Empty(SE5->E5_FILORIG) .and. !(Empty(cFilialSE2)) .and. (cFilialSE1 <> SE5->E5_FILORIG)
						cFilialSE2 := SE5->E5_FILORIG
						lLimpar := !dbSeek(cFilialSE2 + SE5->(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO))
					Endif
				Endif	
				if lLimpar
					//Limpar a chave do relacionamento.
					RecLock("SE5",.F.)
					REPLACE E5_KEY 		With E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO
					REPLACE E5_PREFIXO 	With ""
					REPLACE E5_NUMERO		With ""
					REPLACE E5_PARCELA 	With ""
					REPLACE E5_TIPO		With ""
					MsUnLock()				
				Endif
				//<<< Corrige a integridade com o E1. 
			
			Endif
		Endif	
		DbSelectArea(cAlias)
		DbSkip()
	EndDo 
	#IFNDEF TOP
		dbSelectArea("SE5")
		dbClearFil()
		RetIndex( "SE5" )
		If !Empty(cIndex)
			FErase (cIndex+OrdBagExt())
		Endif
		dbSetOrder(1)
	#ELSE
		dbSelectArea("TRBSE5")
		dbCloseArea()
		dbSelectArea("SE5")
		dbSetOrder(1)
	#ENDIF

	#IFDEF TOP
		Endif
	#ENDIF

	If Empty(xFilial("SE5")) .and. !File(cFile)		/// SE O SE1 ESTIVER COMPARTILHADO E NÃO EXISTIR O ARQUIVO DE LOG EM DISCO
		nHdlFile := MsFCreate(cFile,0)				/// CRIA O ARQUIVO DE LOG (FLAG) PARA INDICAR QUE NÃO DEVE PROCESSAR NOVAMENTE.
		If nHdlFile > 0
			FWRITE(nHdlFile,"Este arquivo pode ser excluido apos a atualizacao de versao."+CHR(13)+CHR(10)+;
							"This file can be erased after the version update."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
							"Arquivo SE5 - Empresa "+cEmpAnt +" - compartilhado - concluido."+CHR(13)+CHR(10)+;
							"SE5 File - Company "+cEmpAnt +" - shared - finished."+CHR(13)+CHR(10),312)
			FClose(nHdlFile)
		EndIf
	EndIf

EndIf

RestArea(aSaveArea)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SE5811Proc³ Autor ³ Alice Y Yamamoto      ³ Data ³ 20.01.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procedure p/ a gravacao do campo SE5                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SE5811Proc                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaFIN                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SE5811Proc()
Local cQuery :=""
Local nTam   := 0

cQuery :="Create Procedure SE5811_"+cEmpAnt+"("+CRLF
nTam := TamSX3("E5_FILIAL")[1]
cQuery +="   @IN_FILIAL     Char( "+StrZero(nTam, 2)+" ),"+CRLF
cQuery +="   @IN_MV_PAGANT  VarChar( 250 ),"+CRLF
cQuery +="   @IN_MV_CPNEG   VarChar( 250 ),"+CRLF
cQuery +="   @IN_MV_RECANT  VarChar( 250 ),"+CRLF
cQuery +="   @IN_MV_CRNEG   VarChar( 250 ),"+CRLF
cQuery +="   @OUT_RESULT    Char( 01 ) OutPut"+CRLF
cQuery +=" )"+CRLF
cQuery +="as"+CRLF

cQuery +="Declare @cAux        VarChar( 03 )"+CRLF
cQuery +="Declare @cFilial     char( "+StrZero(nTam, 2)+" )"+CRLF
cQuery +="Declare @cFil_SE1    char( "+StrZero(nTam, 2)+" )"+CRLF
cQuery +="Declare @cFil_SE2    char( "+StrZero(nTam, 2)+" )"+CRLF
cQuery +="Declare @cFil_SE5    char( "+StrZero(nTam, 2)+" )"+CRLF
cQuery +="Declare @cE5_FILORIG char( "+StrZero(nTam, 2)+" )"+CRLF
nTam := TamSX3("E5_PREFIXO")[1]
cQuery +="Declare @cE5_PREFIXO char( "+StrZero(nTam,2)+" )"+CRLF
nTam := TamSX3("E5_NUMERO")[1]
cQuery +="Declare @cE5_NUMERO  char( "+StrZero(nTam,2)+" )"+CRLF
nTam := TamSX3("E5_PARCELA")[1]
cQuery +="Declare @cE5_PARCELA char( "+StrZero(nTam,2)+" )"+CRLF
nTam := TamSX3("E5_TIPO")[1]
cQuery +="Declare @cE5_TIPO    char( "+StrZero(nTam,2)+" )"+CRLF
nTam := TamSX3("E5_RECPAG")[1]
cQuery +="Declare @cE5_RECPAG  char( "+StrZero(nTam,2)+" )"+CRLF
nTam := TamSX3("E5_TIPODOC")[1]
cQuery +="Declare @cE5_TIPODOC char( "+StrZero(nTam,2)+" )"+CRLF
nTam := TamSX3("E5_CLIFOR")[1]
cQuery +="Declare @cE5_CLIFOR  char( "+StrZero(nTam,2)+" )"+CRLF
nTam := TamSX3("E5_FORNECE")[1]
cQuery +="Declare @cE5_FORNECE char( "+StrZero(nTam,2)+" )"+CRLF
nTam := TamSX3("E5_KEY")[1]
cQuery +="Declare @cE5_KEY     char( "+StrZero(nTam,2)+" )"+CRLF   
cQuery +="Declare @iRecno      Integer"+CRLF
cQuery +="Declare @iRecnoAux   integer"+CRLF
cQuery +="Declare @iPosCli     integer"+CRLF
cQuery +="Declare @iPosFor     integer"+CRLF
cQuery +="Declare @lCliente    char( 01 )"+CRLF
cQuery +="Declare @iNroRegs    integer"+CRLF
cQuery +="Declare @iTranCount  integer"+CRLF 
cQuery +="Declare @lLimpa      Char( 01 )"+CRLF

cQuery +="begin"+CRLF
cQuery +="   select @OUT_RESULT = '0'"+CRLF
cQuery +="   SELECT @cE5_KEY    = ''"+CRLF
cQuery +="   select @iNroRegs = 0"+CRLF
cQuery +="   "+CRLF
cQuery +="   Select @cAux = 'SE1'"+CRLF
cQuery +="   exec XFILIAL_"+cEmpAnt+" @cAux, @IN_FILIAL, @cFil_SE1 OutPut"+CRLF
cQuery +="   Select @cAux = 'SE2'"+CRLF
cQuery +="   exec XFILIAL_"+cEmpAnt+" @cAux, @IN_FILIAL, @cFil_SE2 OutPut"+CRLF
cQuery +="   Select @cAux = 'SE5'"+CRLF
cQuery +="   exec XFILIAL_"+cEmpAnt+" @cAux, @IN_FILIAL, @cFil_SE5 OutPut"+CRLF
cQuery +="   "+CRLF
cQuery +="   declare CUR_SE5 cursor for"+CRLF
cQuery +="   select E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_RECPAG, E5_TIPODOC, E5_CLIFOR, E5_FORNECE, E5_FILORIG, R_E_C_N_O_"+CRLF
cQuery +="    from "+RetSqlName("SE5")+CRLF
cQuery +="   where E5_FILIAL   = @cFil_SE5"+CRLF
cQuery +="     and E5_CLIFOR  != ' '"+CRLF
cQuery +="     and E5_NUMERO  != ' '"+CRLF
cQuery +="     and D_E_L_E_T_  = ' '"+CRLF
cQuery +="   for read only"+CRLF
cQuery +="   "+CRLF
cQuery +="   open  CUR_SE5"+CRLF
cQuery +="   fetch CUR_SE5 into @cFilial, @cE5_PREFIXO, @cE5_NUMERO, @cE5_PARCELA, @cE5_TIPO, @cE5_RECPAG, @cE5_TIPODOC,@cE5_CLIFOR, @cE5_FORNECE, @cE5_FILORIG, @iRecno"+CRLF
cQuery +="   "+CRLF
cQuery +="   while (@@fetch_status = 0) begin"+CRLF
cQuery +="      select @lLimpa = '0'"+CRLF
cQuery +="      select @iPosCli = 0"+CRLF
cQuery +="      select @iPosFor = 0"+CRLF
cQuery +="      select @lCliente = '0'"+CRLF
cQuery +="      select @iNroRegs = @iNroRegs + 1"+CRLF
cQuery +="      "+CRLF
cQuery +="      select @iPosFor = Charindex(@cE5_TIPO, @IN_MV_PAGANT||'/'||@IN_MV_CPNEG)"+CRLF
cQuery +="      select @iPosCli = Charindex(@cE5_TIPO, @IN_MV_RECANT||'/'||@IN_MV_CRNEG)"+CRLF
cQuery +="      "+CRLF
cQuery +="      If @iPosFor = 1 begin"+CRLF
cQuery +="         select @lCliente = '0'"+CRLF
cQuery +="      end else begin"+CRLF
cQuery +="         If @iPosCli = 1 begin"+CRLF
cQuery +="            select @lCliente = '1'"+CRLF
cQuery +="         end else begin"+CRLF
cQuery +="            If @cE5_RECPAG = 'R' and @cE5_TIPODOC = 'ES' begin"+CRLF
cQuery +="               select @lCliente = '0'"+CRLF
cQuery +="            end else begin"+CRLF
cQuery +="               If @cE5_RECPAG = 'P' and @cE5_TIPODOC = 'ES' begin"+CRLF
cQuery +="                  select @lCliente = '1'"+CRLF
cQuery +="               end else begin"+CRLF
cQuery +="                  If @cE5_RECPAG = 'P' select @lCliente = '0'"+CRLF
cQuery +="                  If @cE5_RECPAG = 'R' select @lCliente = '1'"+CRLF
cQuery +="               end"+CRLF
cQuery +="            end"+CRLF
cQuery +="         end"+CRLF
cQuery +="      end"+CRLF
      /* --------------------------------
         Atualizar clientes
         -------------------------------- */
cQuery +="      if @iNroRegs  = 1 begin"+CRLF
cQuery +="         Begin Transaction "+CRLF
cQuery +="         select @iNroRegs  = @iNroRegs "+CRLF
cQuery +="      end"+CRLF
cQuery +="      If @lCliente = '1' begin"+CRLF
cQuery +="         "+CRLF
cQuery +="         UpDate "+RetSqlName("SE5")+CRLF
cQuery +="            Set E5_CLIENTE = @cE5_CLIFOR"+CRLF
cQuery +="          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery +="          "+CRLF
cQuery +="         Select @iRecnoAux = min( R_E_C_N_O_)"+CRLF
cQuery +="           From "+RetSqlName("SE1")+CRLF
cQuery +="          where E1_FILIAL  = @cFil_SE1"+CRLF
cQuery +="            and E1_PREFIXO = @cE5_PREFIXO"+CRLF
cQuery +="            and E1_NUM     = @cE5_NUMERO"+CRLF
cQuery +="            and E1_PARCELA = @cE5_PARCELA"+CRLF
cQuery +="            and E1_TIPO    = @cE5_TIPO"+CRLF
cQuery +="            and D_E_L_E_T_ = ' '"+CRLF
cQuery +="         "+CRLF
cQuery +="         If @iRecnoAux is null select @lLimpa = '1'"+CRLF
cQuery +="         "+CRLF
cQuery +="         If @lLimpa = '1' begin"+CRLF
cQuery +="            If ( @cE5_FILORIG != ' ')  and ( @cFil_SE1 != @cE5_FILORIG ) begin"+CRLF
cQuery +="               Select @iRecnoAux = min( R_E_C_N_O_)"+CRLF
cQuery +="                 From "+RetSqlName("SE1")+CRLF
cQuery +="                where E1_FILIAL  = @cE5_FILORIG"+CRLF
cQuery +="                  and E1_PREFIXO = @cE5_PREFIXO"+CRLF
cQuery +="                  and E1_NUM     = @cE5_NUMERO"+CRLF
cQuery +="                  and E1_PARCELA = @cE5_PARCELA"+CRLF
cQuery +="                  and E1_TIPO    = @cE5_TIPO"+CRLF
cQuery +="                  and D_E_L_E_T_ = ' '"+CRLF
cQuery +="            End"+CRLF
cQuery +="            If @iRecnoAux is null select @lLimpa = '1'"+CRLF
cQuery +="         End"+CRLF
cQuery +="         "+CRLF         
cQuery +="         If @lLimpa = '1' begin"+CRLF
cQuery +="            select @cE5_KEY = @cE5_PREFIXO||@cE5_NUMERO||@cE5_PARCELA||@cE5_TIPO"+CRLF
cQuery +="            "+CRLF
cQuery +="            UpDate "+RetSqlName("SE5")+CRLF
cQuery +="               Set E5_KEY = @cE5_KEY, E5_PREFIXO = ' ', E5_NUMERO = ' ', E5_PARCELA = ' ', E5_TIPO = ' '"+CRLF
cQuery +="             Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery +="         end"+CRLF
cQuery +="      end else begin"+CRLF
         /* --------------------------------
            Atualizar Fornecedores
            -------------------------------- */
cQuery +="         UpDate "+RetSqlName("SE5")+CRLF
cQuery +="            Set E5_FORNECE = @cE5_FORNECE"+CRLF
cQuery +="         Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery +="         "+CRLF
cQuery +="         Select @iRecnoAux = min( R_E_C_N_O_)"+CRLF
cQuery +="           From "+RetSqlName("SE2")+CRLF
cQuery +="          where E2_FILIAL  = @cFil_SE2"+CRLF
cQuery +="            and E2_PREFIXO = @cE5_PREFIXO"+CRLF
cQuery +="            and E2_NUM     = @cE5_NUMERO"+CRLF
cQuery +="            and E2_PARCELA = @cE5_PARCELA"+CRLF
cQuery +="            and E2_TIPO    = @cE5_TIPO"+CRLF
cQuery +="            and D_E_L_E_T_ = ' '"+CRLF
cQuery +="         "+CRLF
cQuery +="         If @iRecnoAux is null select @lLimpa = '1'"+CRLF
cQuery +="         "+CRLF
cQuery +="         If @lLimpa = '1' begin"+CRLF
cQuery +="            If ( @cE5_FILORIG != ' ')  and ( @cFil_SE1 != @cE5_FILORIG ) begin"+CRLF
cQuery +="               Select @iRecnoAux = min( R_E_C_N_O_)"+CRLF
cQuery +="                 From "+RetSqlName("SE1")+CRLF
cQuery +="                where E1_FILIAL  = @cE5_FILORIG"+CRLF
cQuery +="                  and E1_PREFIXO = @cE5_PREFIXO"+CRLF
cQuery +="                  and E1_NUM     = @cE5_NUMERO"+CRLF
cQuery +="                  and E1_PARCELA = @cE5_PARCELA"+CRLF
cQuery +="                  and E1_TIPO    = @cE5_TIPO"+CRLF
cQuery +="                  and D_E_L_E_T_ = ' '"+CRLF
cQuery +="            End"+CRLF
cQuery +="            If @iRecnoAux is null select @lLimpa = '1'"+CRLF
cQuery +="         End"+CRLF
cQuery +="         "+CRLF
cQuery +="         If @lLimpa = '1' begin"+CRLF
cQuery +="            select @cE5_KEY = @cE5_PREFIXO||@cE5_NUMERO||@cE5_PARCELA||@cE5_TIPO"+CRLF
cQuery +="            "+CRLF
cQuery +="            UpDate "+RetSqlName("SE5")+CRLF
cQuery +="               Set E5_KEY = @cE5_KEY, E5_PREFIXO = ' ', E5_NUMERO = ' ', E5_PARCELA = ' ', E5_TIPO = ' '"+CRLF
cQuery +="             Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery +="         end"+CRLF
cQuery +="      end"+CRLF
cQuery +="      if @iNroRegs  >= 4096 begin"+CRLF
cQuery +="         Commit Transaction "+CRLF
cQuery +="         select @iNroRegs  = 0"+CRLF
cQuery +="      end"+CRLF
If Trim(TcGetDb()) = 'DB2'
	cQuery += "      SELECT @fim_CUR = 0"+CRLF
EndIf
cQuery +="      "+CRLF
cQuery +="      fetch CUR_SE5 into @cFilial, @cE5_PREFIXO, @cE5_NUMERO, @cE5_PARCELA, @cE5_TIPO, @cE5_RECPAG, @cE5_TIPODOC,@cE5_CLIFOR, @cE5_FORNECE, @cE5_FILORIG, @iRecno"+CRLF
cQuery +="   end"+CRLF
cQuery +="   if @iNroRegs  > 0 begin"+CRLF
cQuery +="      Commit Transaction "+CRLF
cQuery +="      select @iTranCount = 0"+CRLF
cQuery +="   end"+CRLF
cQuery +="   close CUR_SE5"+CRLF
cQuery +="   Deallocate CUR_SE5"+CRLF
cQuery +="   select @OUT_RESULT = '1'"+CRLF
cQuery +="end"+CRLF

cQuery := MsParse(cQuery,Alltrim(TcGetDB()))
cQuery := CtbAjustaP(.F., cQuery, 0)

Return(cQuery)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Filial()  ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a filial da tabela                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Filial()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SE5811Proc                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Filial()
Local cQuery :=""
Local lRet   := .T.
Local nRet   := 0

cQuery :="Create procedure XFILIAL_"+cEmpAnt+CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_ALIAS        Char(03),"+CRLF
cQuery +="  @IN_FILIALCOR    Char(02),"+CRLF
cQuery +="  @OUT_FILIAL      Char(02) OutPut"+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF
cQuery +="declare @nCont       Integer"+CRLF
cQuery +="begin "+CRLF
cQuery +="  select @nCont = 0"+CRLF
  /* -------------------------------------------------------------------
    Recupera o modo para o alias recebido
  ------------------------------------------------------------------- */
cQuery +="  select @nCont = isnull(Count(*),0) from SX2"+cEmpAnt+"0"+CRLF
cQuery +="   where X2_CHAVE = @IN_ALIAS"+CRLF
  /* -------------------------------------------------------------------
    Retorna a filial a ser utilizada
  ------------------------------------------------------------------- */
cQuery +="  if ( @nCont = 0 ) select @OUT_FILIAL = '  '"+CRLF
cQuery +="  else              select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
cQuery +="end"+CRLF

cQuery := MsParse(cQuery,Alltrim(TcGetDB()))

If ExistProc( "XFILIAL" )
	nRet := TcSqlExec("DROP PROCEDURE XFILIAL_"+cEmpAnt)
	If nRet <> 0
		lRet := .F.
	EndIf
EndIf

If lRet
	nRet := TcSqlExec(cQuery)
	If nRet < 0
		lRet := .F.
	EndIf
Endif

Return(lRet)
